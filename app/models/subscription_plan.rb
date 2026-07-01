class SubscriptionPlan < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :plan_features,          dependent: :destroy
  has_many :account_subscriptions,  dependent: :restrict_with_error

  enum :plan_type, { free: 0, paid: 1 }, prefix: true

  validates :name,          presence: true, uniqueness: { case_sensitive: false }
  validates :slug,          presence: true, uniqueness: true
  validates :monthly_price, numericality: { greater_than_or_equal_to: 0 }
  validates :yearly_price,  numericality: { greater_than_or_equal_to: 0 }
  validates :priority,      numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :trial_days,    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :currency,      format: { with: /\A[A-Z]{3}\z/ }

  scope :active,   -> { where(active: true) }
  scope :ordered,  -> { order(priority: :desc, name: :asc) }
  scope :visible,  -> { active.ordered }

  def feature(key)
    plan_features.find_by(feature_key: key.to_s)
  end

  def feature_value(key)
    feature(key)&.typed_value
  end

  def yearly_savings
    return 0 if monthly_price.zero?
    (monthly_price * 12) - yearly_price
  end

  def yearly_discount_percent
    return 0 if monthly_price.zero?
    ((yearly_savings / (monthly_price * 12)) * 100).round
  end

  def free?
    plan_type_free?
  end
end
