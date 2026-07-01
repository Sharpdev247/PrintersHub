class SubscriptionUsage < ApplicationRecord
  belongs_to :account_subscription
  belongs_to :account

  validates :feature_key,  presence: true
  validates :quantity,     numericality: { greater_than_or_equal_to: 0 }
  validates :period_start, presence: true
  validates :feature_key,  uniqueness: { scope: [:account_id, :period_start] }

  scope :current_period, -> { where(period_start: Date.current.beginning_of_month) }
  scope :for_feature,    ->(key) { where(feature_key: key) }
end
