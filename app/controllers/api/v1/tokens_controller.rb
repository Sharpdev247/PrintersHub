class Api::V1::TokensController < ActionController::API
  # Token creation/revocation uses Devise session auth, not token auth.
  before_action :authenticate_user!
  before_action :set_current_context

  # POST /api/v1/tokens
  def create
    token, raw = ApiToken.generate!(
      account:    Current.account,
      user:       current_user,
      name:       token_params[:name],
      token_type: token_params[:token_type] || "personal",
      scopes:     Array(token_params[:scopes]),
      expires_at: parse_expiry(token_params[:expires_in_days])
    )

    render json: {
      id:         token.id,
      name:       token.name,
      token:      raw,           # shown ONCE — user must copy it now
      prefix:     token.prefix,
      token_type: token.token_type,
      scopes:     token.scopes,
      expires_at: token.expires_at,
      created_at: token.created_at,
      message:    "Copy this token now — it will not be shown again."
    }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  # DELETE /api/v1/tokens/:id
  def destroy
    token = current_user.api_tokens.find(params[:id])
    token.revoke!
    render json: { message: "Token revoked." }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Token not found." }, status: :not_found
  end

  # GET /api/v1/tokens
  def index
    tokens = Current.account.api_tokens
                    .where(user: current_user)
                    .order(created_at: :desc)

    render json: tokens.map { |t|
      {
        id:          t.id,
        name:        t.name,
        prefix:      t.display_token,
        token_type:  t.token_type,
        scopes:      t.scopes,
        active:      t.active?,
        last_used_at: t.last_used_at,
        expires_at:  t.expires_at,
        created_at:  t.created_at
      }
    }
  end

  private

  def token_params
    params.require(:token).permit(:name, :token_type, :expires_in_days, scopes: [])
  end

  def parse_expiry(days)
    return nil if days.blank?
    days.to_i.days.from_now
  end

  def set_current_context
    Current.user    = current_user
    Current.account = current_user.primary_account
  end
end
