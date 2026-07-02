class Users::PasswordsController < Devise::PasswordsController
  layout "auth"
  # GET /forgot-password
  def new
    super
  end

  # POST /forgot-password
  def create
    super
  end

  # GET /reset-password?reset_password_token=...
  def edit
    super
  end

  # PATCH /reset-password
  def update
    super
  end

  private

  def after_resetting_password_path_for(resource)
    new_user_session_path
  end

  def after_sending_reset_password_instructions_path_for(resource_name)
    new_user_session_path
  end
end
