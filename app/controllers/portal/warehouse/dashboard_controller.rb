module Portal
  module Warehouse
    class DashboardController < Portal::BaseController
      before_action :require_warehouse_access

      def show
        account_warehouses = Current.account.warehouses.kept

        @warehouses_count  = account_warehouses.count
        @active_warehouses = account_warehouses.active.count

        # Aggregate stock across all warehouses for this account
        items = InventoryItem.joins(:warehouse)
                             .where(warehouses: { account_id: Current.account.id })
                             .active

        @total_skus        = items.count
        @low_stock_count   = items.low_stock.count
        @out_of_stock_count = items.out_of_stock.count
        @total_on_hand     = items.sum(:quantity_on_hand)
        @total_reserved    = items.sum(:reserved_quantity)

        @low_stock_items   = items.low_stock
                                  .includes(product_variant: :product, warehouse: {})
                                  .order("quantity_on_hand - reserved_quantity ASC")
                                  .limit(10)

        @warehouses = account_warehouses.active
                                        .includes(:inventory_items)
                                        .order(:name)
      end

      private

      def require_warehouse_access
        unless Current.role.in?(%w[owner admin manager warehouse_staff])
          redirect_to portal_root_path, alert: "Access denied."
        end
      end
    end
  end
end
