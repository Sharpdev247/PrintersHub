class Users::RegistrationsController < Devise::RegistrationsController
  layout "auth"
  before_action :configure_sign_up_params,   only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /register
  def new
    super
  end

  # POST /register
  def create
    super do |resource|
      if resource.persisted?
        create_account_for(resource)
      end
    end
  end

  # GET /profile/edit
  def edit
    super
  end

  # PATCH /profile
  def update
    super
  end

  # DELETE /profile
  def destroy
    super
  end

  private

  # Build the account and owner membership immediately after user creation.
  # The account name comes from the registration form param :account_name.
  def create_account_for(user)
    account_name = sign_up_params[:account_name].presence || "#{user.email.split('@').first}'s Account"

    account = Account.create!(
      name:         account_name,
      account_type: :individual,
      status:       :active
    )

    account.memberships.create!(
      user:  user,
      role:  :owner
    )
  rescue => e
    Rails.logger.error "Account creation failed for user #{user.id}: #{e.message}"
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:account_name])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end

  def after_sign_up_path_for(resource)
    welcome_path
  end

  def after_inactive_sign_up_path_for(resource)
    # Confirmable is on — user must confirm email before logging in.
    new_user_session_path
  end
end
