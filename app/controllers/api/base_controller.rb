class Api::BaseController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_api_token!
  before_action :set_current_context

  rescue_from ActiveRecord::RecordNotFound,    with: :not_found
  rescue_from ActiveRecord::RecordInvalid,     with: :unprocessable
  rescue_from ActionController::ParameterMissing, with: :bad_request

  private

  def authenticate_api_token!
    raw = extract_token_from_request
    @current_api_token = ApiToken.authenticate(raw)

    render json: { error: "Invalid or expired API token" }, status: :unauthorized unless @current_api_token
  end

  def set_current_context
    Current.user    = @current_api_token.user
    Current.account = @current_api_token.account
    Audited.store[:current_user] = Current.user
  end

  def current_api_token = @current_api_token
  def current_user      = Current.user
  def current_account   = Current.account

  # Enforce scope on individual actions:
  #   require_scope! "write:orders"
  def require_scope!(scope)
    return if current_api_token.has_scope?(scope)

    render json: { error: "Token missing required scope: #{scope}" }, status: :forbidden
  end

  def extract_token_from_request
    # Accept: Authorization: Bearer phb_...
    # or:     Authorization: Token token=phb_...
    header = request.headers["Authorization"].to_s
    if header.start_with?("Bearer ")
      header.delete_prefix("Bearer ").strip
    elsif header.start_with?("Token ")
      header.match(/token=["']?([^"'\s]+)["']?/i)&.captures&.first
    end
  end

  # ── Error helpers ────────────────────────────────────────────────────────────

  def not_found(e)
    render json: { error: e.message }, status: :not_found
  end

  def unprocessable(e)
    render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def bad_request(e)
    render json: { error: e.message }, status: :bad_request
  end

  def render_error(message, status: :unprocessable_entity)
    render json: { error: message }, status: status
  end
end
