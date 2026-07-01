class PlanFeature < ApplicationRecord
  FEATURE_KEYS = %w[
    max_listings
    featured_listings
    max_team_members
    api_access
    analytics
    crm_module
    warehouse_module
    repair_module
    priority_notifications
    storage_gb
    max_api_requests_per_day
    messages_per_day
    support_level
  ].freeze

  FEATURE_TYPES = %w[boolean limit string].freeze

  belongs_to :subscription_plan

  validates :feature_key,  presence: true, inclusion: { in: FEATURE_KEYS }
  validates :feature_type, presence: true, inclusion: { in: FEATURE_TYPES }
  validates :value,        presence: true
  validates :display_name, presence: true
  validates :feature_key,  uniqueness: { scope: :subscription_plan_id }

  def typed_value
    case feature_type
    when "boolean" then value == "true"
    when "limit"   then unlimited? ? Float::INFINITY : value.to_i
    when "string"  then value
    end
  end

  def unlimited?
    value == "unlimited"
  end

  def numeric_value
    unlimited? ? Float::INFINITY : value.to_i
  end

  def boolean_feature?
    feature_type == "boolean"
  end

  def limit_feature?
    feature_type == "limit"
  end
end
