module Portal
  module Crm
    class DashboardController < Portal::BaseController
      before_action :require_sales_access

      def show
        base = policy_scope(Contact)

        @stats = {
          total:     base.count,
          leads:     base.leads.count,
          customers: base.customers.count,
          active:    base.active.count,
        }

        @overdue_follow_ups = ContactNote.overdue
                                         .joins(:contact)
                                         .where(contacts: { account: Current.account, discarded_at: nil })
                                         .includes(:contact, :author)
                                         .limit(8)

        @upcoming_follow_ups = ContactNote.upcoming
                                          .joins(:contact)
                                          .where(contacts: { account: Current.account, discarded_at: nil })
                                          .includes(:contact, :author)
                                          .limit(8)

        @recent_contacts = base.recent.includes(:owner).limit(8)
      end

      private

      def require_sales_access
        unless Current.role.in?(%w[owner admin manager sales])
          redirect_to portal_root_path, alert: "Access denied."
        end
      end
    end
  end
end
