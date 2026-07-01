class AccountSubscription < ApplicationRecord
  include Discard::Model
  audited

  belongs_to :account
  belongs_to :subscription_plan
  belongs_to :coupon_redemption, optional: true

  has_many :invoices, dependent: :nullify
  has_many :subscription_usages, dependent: :destroy

  enum :status, {
    trialing:   0,
    active:     1,
    past_due:   2,
    cancelled:  3,
    expired:    4,
    suspended:  5
  }, prefix: true

  validates :billing_interval, presence: true,
                               inclusion: { in: %w[monthly yearly] }
  validates :current_price,    numericality: { greater_than_or_equal_to: 0 }
  validates :currency,         format: { with: /\A[A-Z]{3}\z/ }

  scope :live,      -> { kept.where(status: [statuses[:trialing], statuses[:active], statuses[:past_due]]) }
  scope :active,    -> { kept.status_active }
  scope :cancelled, -> { kept.status_cancelled }

  def live?
    status_trialing? || status_active? || status_past_due?
  end

  def trialing?
    status_trialing? && trial_ends_at&.future?
  end

  def cancel!(time = Time.current)
    update!(status: :cancelled, cancelled_at: time)
  end

  def suspend!
    update!(status: :suspended)
  end

  def reactivate!
    update!(status: :active, cancelled_at: nil)
  end

  def usage_for(feature_key, period: Date.current.beginning_of_month)
    subscription_usages.find_by(feature_key: feature_key, period_start: period)&.quantity || 0
  end

  def increment_usage!(feature_key, by: 1, period: Date.current.beginning_of_month)
    usage = subscription_usages.find_or_initialize_by(
      account:     account,
      feature_key: feature_key,
      period_start: period
    )
    usage.quantity ||= 0
    usage.quantity  += by
    usage.period_end = period.end_of_month
    usage.save!
  end
end
