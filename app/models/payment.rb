class Payment < ApplicationRecord
  audited

  belongs_to :account
  belongs_to :invoice, optional: true
  belongs_to :order, optional: true
  has_many :payment_transactions, dependent: :destroy

  enum :payment_context, { subscription: 0, order: 1 }, prefix: true

  enum :status, {
    pending:   0,
    completed: 1,
    failed:    2,
    refunded:  3
  }, prefix: true

  validates :amount,   numericality: { greater_than: 0 }
  validates :currency, format: { with: /\A[A-Z]{3}\z/ }
  validate  :invoice_belongs_to_same_account

  scope :completed,        -> { status_completed }
  scope :recent,           -> { order(created_at: :desc) }
  scope :for_provider,     ->(p) { where(payment_provider: p) }
  scope :for_order,        -> { payment_context_order }
  scope :for_subscription, -> { payment_context_subscription }

  def mark_completed!(time = Time.current)
    update!(status: :completed, paid_at: time)
  end

  def mark_failed!(reason: nil)
    update!(status: :failed, failure_reason: reason)
  end

  private

  def invoice_belongs_to_same_account
    return unless invoice_id.present?
    unless invoice&.account_id == account_id
      errors.add(:invoice, "must belong to the same account")
    end
  end
end
