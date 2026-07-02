class Users::SessionsController < Devise::SessionsController
  layout "auth"
  # GET /login
  def new
    super
  end

  # POST /login
  def create
    super
  end

  # DELETE /logout
  def destroy
    super
  end

  private

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || portal_path
  end

  def after_sign_out_path_for(_resource)
    root_path
  end
end
