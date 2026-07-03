module Portal
  module Service
    class DashboardController < Portal::BaseController
      before_action :require_service_access

      def show
        base = policy_scope(ServiceRequest)

        @stats = {
          total:           base.count,
          open:            base.open.count,
          in_progress:     base.by_status("in_progress").count,
          scheduled_today: base.by_status("scheduled").where(scheduled_at: Time.current.beginning_of_day..Time.current.end_of_day).count,
          completed_month: base.by_status("completed").where(completed_at: Time.current.beginning_of_month..).count,
          urgent:          base.open.urgent.count,
          overdue:         base.overdue.count
        }

        @recent       = base.open.recent.includes(:assigned_to, :printer_model, :customer_account).limit(8)
        @my_requests  = base.open.where(assigned_to: current_user).recent.limit(5)
        @technicians  = Current.account.memberships.kept.where(role: Membership.roles[:technician])
                                                       .includes(:user).order(:created_at)
      end

      private

      def require_service_access
        unless Current.role.in?(%w[owner admin manager technician])
          redirect_to portal_root_path, alert: "Access denied."
        end
      end
    end
  end
end
