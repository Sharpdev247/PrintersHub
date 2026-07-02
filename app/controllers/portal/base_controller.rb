class Portal::BaseController < ApplicationController
  include AccountScoped

  layout "portal"

  rescue_from SubscriptionEnforcer::LimitError do |e|
    redirect_to portal_subscription_plans_path, alert: e.message
  end
end
