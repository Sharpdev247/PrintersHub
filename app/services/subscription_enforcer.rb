# Checks whether an account is allowed to perform a feature-gated action.
#
# Usage:
#   enforcer = SubscriptionEnforcer.new(account)
#   enforcer.allow?(:max_listings)          # boolean
#   enforcer.enforce!(:api_access)          # raises SubscriptionEnforcer::LimitError
#   enforcer.usage(:max_listings)           # {used: 3, limit: 10, unlimited: false}
#
class SubscriptionEnforcer
  class LimitError < StandardError
    attr_reader :feature_key, :limit, :used, :plan_name

    def initialize(feature_key:, limit:, used:, plan_name:)
      @feature_key = feature_key
      @limit       = limit
      @used        = used
      @plan_name   = plan_name
      super(build_message)
    end

    def upgrade_required? = true

    private

    def build_message
      case @feature_key.to_s
      when "max_listings"
        "Your #{@plan_name} plan allows #{@limit == Float::INFINITY ? 'unlimited' : @limit} listings. " \
        "You have #{@used}. Upgrade to add more."
      when "api_access"
        "API access is not included in your #{@plan_name} plan. Upgrade to enable it."
      when "max_team_members"
        "Your #{@plan_name} plan allows #{@limit} team members. You have #{@used}. Upgrade to add more."
      when "analytics"
        "Advanced analytics are not included in your #{@plan_name} plan."
      when "crm_module"
        "The CRM module is not included in your #{@plan_name} plan."
      when "warehouse_module"
        "The Warehouse module is not included in your #{@plan_name} plan."
      when "repair_module"
        "The Service/Repair module is not included in your #{@plan_name} plan."
      else
        "This feature is not available on your #{@plan_name} plan. Please upgrade."
      end
    end
  end

  def initialize(account)
    @account = account
    @plan    = active_plan
  end

  # Returns true if the account is allowed to use/create more of this feature.
  def allow?(feature_key)
    check(feature_key).allowed
  end

  # Raises LimitError if the account cannot use this feature.
  def enforce!(feature_key)
    result = check(feature_key)
    raise LimitError.new(
      feature_key: feature_key,
      limit:       result.limit,
      used:        result.used,
      plan_name:   @plan&.name || "Free"
    ) unless result.allowed
    true
  end

  # Returns {used:, limit:, unlimited:, percent:} for display in UI.
  def usage(feature_key)
    feature = plan_feature(feature_key)
    limit   = feature&.typed_value

    used = case feature_key.to_s
           when "max_listings"      then @account.listings.kept.count
           when "max_team_members"  then @account.memberships.kept.count
           when "storage_gb"        then 0  # extend when Active Storage billing lands
           else 0
           end

    unlimited = limit == Float::INFINITY || limit.nil?
    percent   = unlimited ? 0 : limit.zero? ? 100 : [(used.to_f / limit * 100).round, 100].min

    { used: used, limit: unlimited ? nil : limit, unlimited: unlimited, percent: percent }
  end

  # Returns all feature usages for the billing dashboard.
  def all_usages
    PlanFeature::FEATURE_KEYS.index_with { |key| usage(key) }
  end

  def plan_name
    @plan&.name || "Free"
  end

  def has_active_subscription?
    active_subscription.present?
  end

  def on_free_plan?
    @plan.nil? || @plan.plan_type_free?
  end

  private

  Result = Struct.new(:allowed, :limit, :used)

  def check(feature_key)
    feature = plan_feature(feature_key)

    # No feature definition means the plan doesn't include it at all.
    if feature.nil?
      return Result.new(false, 0, 0)
    end

    case feature.feature_type
    when "boolean"
      Result.new(feature.typed_value, nil, nil)
    when "limit"
      limit = feature.typed_value
      used  = current_usage(feature_key)
      Result.new(limit == Float::INFINITY || used < limit, limit, used)
    when "string"
      # String features are informational, never block access.
      Result.new(true, nil, nil)
    else
      Result.new(false, 0, 0)
    end
  end

  def current_usage(feature_key)
    case feature_key.to_s
    when "max_listings"      then @account.listings.kept.count
    when "max_team_members"  then @account.memberships.kept.count
    else
      # For monthly-metered features, check SubscriptionUsage records.
      active_subscription&.usage_for(feature_key.to_s) || 0
    end
  end

  def plan_feature(feature_key)
    @plan&.feature(feature_key)
  end

  def active_plan
    active_subscription&.subscription_plan
  end

  def active_subscription
    @active_subscription ||= @account.memberships
      .then { @account.account_subscriptions.kept.live.includes(:subscription_plan).first }
  end
end
