module PublicAccessible
  extend ActiveSupport::Concern

  included do
    # Public controllers do not require login.
    skip_before_action :authenticate_user!

    # Still set context if the user happens to be signed in.
    before_action :set_public_context
  end

  private

  def set_public_context
    return unless current_user

    Current.user    = current_user
    Current.account = resolve_current_account
    Audited.store[:current_user] = current_user
  end
end
