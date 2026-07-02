module Portal
  class SubscriptionsController < Portal::BaseController
    before_action :require_owner

    # GET /portal/subscription — current plan + usage dashboard
    def show
      @enforcer     = SubscriptionEnforcer.new(Current.account)
      @subscription = Current.account.account_subscriptions.kept.live
                             .includes(:subscription_plan).first
      @plan         = @subscription&.subscription_plan
      @plans        = SubscriptionPlan.visible.includes(:plan_features)
    end

    # GET /portal/subscription/plans — pricing table
    def plans
      @plans    = SubscriptionPlan.visible.includes(:plan_features)
      @current  = Current.account.active_subscription&.subscription_plan
    end

    # POST /portal/subscription — subscribe to a plan
    def create
      plan = SubscriptionPlan.find(params[:plan_id])

      existing = Current.account.account_subscriptions.kept.live.first
      if existing
        # Upgrade/downgrade: cancel current, create new
        existing.cancel!(Time.current)
      end

      interval = params[:interval].presence_in(%w[monthly yearly]) || "monthly"
      price    = interval == "yearly" ? plan.yearly_price : plan.monthly_price
      trial_ends = plan.trial_days.to_i > 0 ? plan.trial_days.days.from_now : nil

      sub = Current.account.account_subscriptions.create!(
        subscription_plan: plan,
        billing_interval:  interval,
        current_price:     price,
        currency:          plan.currency,
        status:            trial_ends ? :trialing : :active,
        trial_ends_at:     trial_ends,
        current_period_start: Time.current,
        current_period_end:   interval == "yearly" ? 1.year.from_now : 1.month.from_now
      )

      # Track usage reset for the new period
      sub.increment_usage!("max_listings", by: 0)

      redirect_to portal_subscription_path,
        notice: "Subscribed to #{plan.name}#{trial_ends ? ' — trial period started' : ''}."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to portal_subscription_plans_path, alert: e.record.errors.full_messages.to_sentence
    end

    # DELETE /portal/subscription — cancel
    def destroy
      sub = Current.account.account_subscriptions.kept.live.first
      if sub
        sub.cancel!
        redirect_to portal_subscription_path, notice: "Subscription cancelled. Access continues until the end of the current period."
      else
        redirect_to portal_subscription_path, alert: "No active subscription to cancel."
      end
    end

    private

    def require_owner
      unless Current.role == "owner"
        redirect_to portal_root_path, alert: "Only the account owner can manage the subscription."
      end
    end
  end
end
