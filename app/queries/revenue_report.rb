# Aggregates order revenue for a given account over a date range.
#
# Usage:
#   RevenueReport.new(account: acct, from: 3.months.ago, to: Time.current).call
#
class RevenueReport
  attr_reader :account, :from, :to, :group_by

  def initialize(account:, from: 30.days.ago, to: Time.current, group_by: :day)
    @account  = account
    @from     = from.beginning_of_day
    @to       = to.end_of_day
    @group_by = group_by
  end

  def call
    {
      summary:       summary,
      by_period:     by_period,
      by_status:     by_status,
      top_listings:  top_listings
    }
  end

  private

  def base_orders
    Order.where(seller_account: account)
         .where(created_at: from..to)
  end

  def summary
    paid = base_orders.where.not(paid_at: nil)
    {
      total_orders:   base_orders.count,
      paid_orders:    paid.count,
      total_revenue:  paid.sum(:total).to_f.round(2),
      avg_order:      paid.average(:total)&.to_f&.round(2) || 0,
      cancelled:      base_orders.where(status: Order.statuses[:cancelled]).count
    }
  end

  def by_period
    fmt = group_by == :month ? "YYYY-MM" : "YYYY-MM-DD"
    rows = ActiveRecord::Base.connection.execute(
      ActiveRecord::Base.sanitize_sql([ <<~SQL, account.id, from, to ])
        SELECT
          TO_CHAR(created_at AT TIME ZONE 'UTC', '#{fmt}') AS period,
          COUNT(*)                                          AS order_count,
          COALESCE(SUM(CASE WHEN paid_at IS NOT NULL THEN total ELSE 0 END), 0) AS revenue
        FROM orders
        WHERE seller_account_id = ?
          AND created_at BETWEEN ? AND ?
        GROUP BY 1
        ORDER BY 1
      SQL
    )
    rows.map { |r| { period: r["period"], orders: r["order_count"].to_i, revenue: r["revenue"].to_f.round(2) } }
  end

  def by_status
    base_orders.group(:status).count.transform_keys(&:humanize)
  end

  def top_listings
    OrderItem.joins(:order)
             .where(orders: { seller_account: account, created_at: from..to })
             .joins("LEFT JOIN listings ON listings.id = order_items.listing_id")
             .group("order_items.listing_id",
                    "order_items.listing_snapshot->>'title'",
                    "listings.title")
             .select(
               "order_items.listing_id",
               "COALESCE(listings.title, order_items.listing_snapshot->>'title', 'Removed listing') AS listing_title",
               "SUM(order_items.total) AS total_revenue",
               "COUNT(*) AS order_count"
             )
             .order("total_revenue DESC")
             .limit(10)
  end
end
