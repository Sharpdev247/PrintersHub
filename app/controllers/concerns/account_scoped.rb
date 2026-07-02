module AccountScoped
  extend ActiveSupport::Concern

  included do
    before_action :require_account!
  end

  private

  # Halt if no active account is resolved — e.g. user invited but not yet
  # accepted into any account.
  def require_account!
    return if Current.account.present?

    flash[:alert] = "Your account is not set up yet. Please complete registration."
    redirect_to root_path
  end

  # Scope a relation to the current tenant account.
  # Usage: account_scope(Listing)  →  Listing.where(account: Current.account)
  def account_scope(klass)
    klass.where(account: Current.account)
  end
end
