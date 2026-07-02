module Portal
  module Settings
    class ProfilesController < Portal::BaseController
      before_action :load_profile

      def show; end

      def update
        if @profile.update(profile_params)
          redirect_to portal_settings_profile_path, notice: "Profile updated."
        else
          render :show, status: :unprocessable_entity
        end
      end

      private

      def load_profile
        @profile = current_user.profile || current_user.create_profile!
      end

      def profile_params
        params.require(:profile).permit(
          :first_name, :last_name, :phone, :bio, :date_of_birth, :locale, :timezone
        )
      end
    end
  end
end
