module Portal
  class ApiTokensController < Portal::BaseController
    before_action :require_admin

    def index
      @tokens = ApiToken.where(account: Current.account)
                        .includes(:user)
                        .order(created_at: :desc)
      @new_token = nil
      @flash_token = flash[:raw_token]
    end

    def create
      token, raw = ApiToken.generate!(
        account:    Current.account,
        user:       current_user,
        name:       token_params[:name],
        token_type: token_params[:token_type].presence || "personal",
        scopes:     Array(token_params[:scopes]).reject(&:blank?),
        expires_at: parse_expiry(token_params[:expires_in_days])
      )

      flash[:raw_token] = raw
      redirect_to portal_api_tokens_path, notice: "Token created. Copy it now — it will not be shown again."
    rescue ActiveRecord::RecordInvalid => e
      @tokens = ApiToken.where(account: Current.account).order(created_at: :desc)
      @flash_token = nil
      flash.now[:alert] = e.record.errors.full_messages.to_sentence
      render :index, status: :unprocessable_entity
    end

    def destroy
      token = ApiToken.where(account: Current.account).find(params[:id])
      token.revoke!
      redirect_to portal_api_tokens_path, notice: "Token revoked."
    end

    private

    def token_params
      params.require(:api_token).permit(:name, :token_type, :expires_in_days, scopes: [])
    end

    def parse_expiry(days)
      return nil if days.blank? || days.to_i.zero?
      days.to_i.days.from_now
    end

    def require_admin
      unless Current.role.in?(%w[owner admin])
        redirect_to portal_root_path, alert: "Access denied."
      end
    end
  end
end
