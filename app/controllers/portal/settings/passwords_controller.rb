module Portal
  module Settings
    class PasswordsController < Portal::BaseController
      def show; end

      def update
        if current_user.update_with_password(password_params)
          # Re-sign in so the session remains valid after password change.
          bypass_sign_in(current_user)
          redirect_to portal_settings_password_path, notice: "Password changed successfully."
        else
          render :show, status: :unprocessable_entity
        end
      end

      private

      def password_params
        params.require(:user).permit(
          :current_password, :password, :password_confirmation
        )
      end
    end
  end
end
