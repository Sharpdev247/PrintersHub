module Portal
  module Reports
    class OverviewController < BaseController
      def show
        acct = Current.account

        # Orders
        orders = Order.where(seller_account: acct).where(created_at: @from..@to)
        @total_revenue   = orders.where.not(paid_at: nil).sum(:total).to_f
        @total_orders    = orders.count
        @avg_order_value = orders.where.not(paid_at: nil).average(:total)&.to_f&.round(2) || 0

        # Listings
        @active_listings = Listing.kept.where(account: acct).where(status: "published").count
        @total_views     = Listing.kept.where(account: acct).sum(:views_count)
        @total_favorites = Listing.kept.where(account: acct)
                                  .joins(:favorites).where(favorites: { created_at: @from..@to }).count

        # Service
        @open_service_requests = ServiceRequest.kept.where(account: acct)
                                               .where.not(status: %w[completed cancelled]).count

        # CRM
        @new_contacts = Contact.kept.where(account: acct).where(created_at: @from..@to).count
        @new_leads    = Contact.kept.where(account: acct, contact_type: "lead")
                               .where(created_at: @from..@to).count

        # Revenue by day/month for sparkline
        @revenue_data = RevenueReport.new(
          account: acct, from: @from, to: @to, group_by: group_by
        ).call[:by_period]
      end
    end
  end
end
