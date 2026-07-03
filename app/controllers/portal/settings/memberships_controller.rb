module Portal
  module Settings
    class MembershipsController < Portal::BaseController
      before_action :require_admin
      before_action :find_membership, only: [ :update, :destroy ]

      def index
        @memberships = policy_scope(Membership)
                         .includes(:user)
                         .order(:role, :created_at)
        @invite_user = User.new
      end

      # POST /portal/settings/memberships — invite by email
      def create
        authorize Membership

        email = params[:email].to_s.strip.downcase
        user  = User.find_by(email: email)

        unless user
          redirect_to portal_settings_memberships_path,
                      alert: "No account found for #{email}. They must register first."
          return
        end

        if Current.account.memberships.kept.exists?(user: user)
          redirect_to portal_settings_memberships_path,
                      alert: "#{email} is already a member of this account."
          return
        end

        membership = Current.account.memberships.new(
          user: user,
          role: params[:role].presence || "sales"
        )

        if membership.save
          redirect_to portal_settings_memberships_path,
                      notice: "#{user.email} has been added as #{membership.role.humanize}."
        else
          redirect_to portal_settings_memberships_path,
                      alert: membership.errors.full_messages.to_sentence
        end
      end

      # PATCH /portal/settings/memberships/:id
      def update
        authorize @membership

        if @membership.update(role: params[:membership][:role])
          redirect_to portal_settings_memberships_path,
                      notice: "Role updated to #{@membership.role.humanize}."
        else
          redirect_to portal_settings_memberships_path,
                      alert: @membership.errors.full_messages.to_sentence
        end
      end

      # DELETE /portal/settings/memberships/:id
      def destroy
        authorize @membership

        if @membership.discard
          redirect_to portal_settings_memberships_path, notice: "Member removed."
        else
          redirect_to portal_settings_memberships_path,
                      alert: @membership.errors.full_messages.to_sentence
        end
      end

      private

      def require_admin
        unless Current.role.in?(%w[owner admin])
          redirect_to portal_settings_profile_path,
                      alert: "Only account owners and admins can manage members."
        end
      end

      def find_membership
        @membership = Current.account.memberships.kept.find(params[:id])
      end
    end
  end
end
