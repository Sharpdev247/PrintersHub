class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :check_maintenance_mode
  before_action :authenticate_user!, unless: :admin_path?
  before_action :set_current_context, unless: :admin_path?

  rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized

  private

  # ── Request context ─────────────────────────────────────────────────────────

  def check_maintenance_mode
    return unless Settings.maintenance_mode?
    return if request.path.start_with?("/admin", "/up")

    render plain: Settings.maintenance_message, status: :service_unavailable
  end

  def set_current_context
    Current.user       = current_user
    Current.account    = resolve_current_account
    Current.request_id = request.uuid
    Current.ip_address = request.remote_ip
    Current.user_agent = request.user_agent

    # Wire audit attribution so every model write records the right user.
    Audited.store[:current_user] = current_user
  end

  # Resolve which account is active for this request.
  # Priority:
  #   1. Explicit switch via ?switch_account=ID param (persisted to session)
  #   2. Session-persisted account id from a previous switch
  #   3. User's primary account (first owner membership)
  def resolve_current_account
    return nil unless current_user

    if params[:switch_account].present?
      account = current_user.accounts.kept.find_by(id: params[:switch_account])
      if account
        session[:current_account_id] = account.id
        return account
      end
    end

    if session[:current_account_id].present?
      account = current_user.accounts.kept.find_by(id: session[:current_account_id])
      return account if account
      # Stale session entry — clear it and fall through.
      session.delete(:current_account_id)
    end

    current_user.primary_account
  end

  # ── Authorization ────────────────────────────────────────────────────────────

  def handle_unauthorized
    respond_to do |format|
      format.html do
        flash[:alert] = "You are not authorized to perform that action."
        redirect_back fallback_location: root_path
      end
      format.json { render json: { error: "Forbidden" }, status: :forbidden }
    end
  end

  # ── Devise after-sign-in path ────────────────────────────────────────────────

  def after_sign_in_path_for(resource)
    session[:created_at] = Time.current.iso8601
    stored_location_for(resource) || (resource.is_a?(AdminUser) ? admin_root_path : portal_path)
  end

  def after_sign_out_path_for(_resource)
    root_path
  end

  def admin_path?
    request.path.start_with?("/admin")
  end

  # Pundit hook stubs — opt in per controller:
  #   after_action :verify_authorized
  #   after_action :verify_policy_scoped
end
