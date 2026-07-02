module Portal
  module Reports
    class InventoryController < BaseController
      def show
        items = InventoryItem.joins(:warehouse)
                             .where(warehouses: { account_id: Current.account.id })
                             .active
                             .includes(:listing, warehouse: {})

        total_value = items.joins(:listing)
                           .sum("inventory_items.quantity_on_hand * listings.price")

        @summary = {
          total_skus:    items.count,
          total_stock:   items.sum(:quantity_on_hand),
          total_value:   total_value,
          out_of_stock:  items.out_of_stock.count,
        }

        @low_stock  = items.low_stock.order(quantity_on_hand: :asc).limit(20)
        @out_of_stock = items.out_of_stock.order(updated_at: :asc).limit(10)

        @by_warehouse = Current.account.warehouses.kept
                               .map { |wh| [wh.name, wh.inventory_items.active.sum(:quantity_on_hand)] }
                               .reject { |_, qty| qty.zero? }

        @recent_adjustments = InventoryTransaction
          .joins(inventory_item: :warehouse)
          .where(warehouses: { account_id: Current.account.id })
          .where(performed_at: @from..@to)
          .includes(:inventory_item)
          .order(performed_at: :desc)
          .limit(25)
      end
    end
  end
end
