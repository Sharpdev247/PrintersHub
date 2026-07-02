class Users::ConfirmationsController < Devise::ConfirmationsController
  layout "auth"
  # GET /confirm-email?confirmation_token=...
  def show
    super
  end

  private

  def after_confirmation_path_for(resource_name, resource)
    if signed_in?(resource_name)
      portal_path
    else
      new_user_session_path
    end
  end
end
