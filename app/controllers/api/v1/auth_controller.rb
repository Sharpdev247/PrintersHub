class Api::V1::AuthController < Api::V1::BaseController
  # GET /api/v1/me
  def me
    render json: {
      user: {
        id:    current_user.id,
        email: current_user.email,
        name:  current_user.full_name
      },
      account: {
        id:           current_account.id,
        name:         current_account.name,
        slug:         current_account.slug,
        account_type: current_account.account_type
      },
      token: {
        id:         current_api_token.id,
        name:       current_api_token.name,
        scopes:     current_api_token.scopes,
        expires_at: current_api_token.expires_at
      }
    }
  end
end
