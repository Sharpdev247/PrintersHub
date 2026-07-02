module Portal
  module Settings
    class AccountsController < Portal::BaseController
      before_action :require_owner_or_admin

      def show
        @account = Current.account
      end

      def update
        @account = Current.account
        if @account.update(account_params)
          redirect_to portal_settings_account_path, notice: "Account settings saved."
        else
          render :show, status: :unprocessable_entity
        end
      end

      private

      def require_owner_or_admin
        unless Current.role.in?(%w[owner admin])
          redirect_to portal_path, alert: "Only account owners and admins can change account settings."
        end
      end

      def account_params
        params.require(:account).permit(:name, :email, :phone, :website, :bio)
      end
    end
  end
end
