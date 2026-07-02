module Portal
  module Warehouse
    class InventoryItemsController < Portal::BaseController
      before_action :require_warehouse_access
      before_action :find_item, only: [:show, :adjust]

      def index
        @warehouse = find_scoped_warehouse
        base = InventoryItem.joins(:warehouse)
                            .where(warehouses: { account_id: Current.account.id })
                            .active
                            .includes(product_variant: :product, warehouse: {})

        base = base.for_warehouse(@warehouse) if @warehouse

        @items = case params[:filter]
                 when "low_stock"   then base.low_stock
                 when "out_of_stock" then base.out_of_stock
                 else base
                 end
                 .order("quantity_on_hand - reserved_quantity ASC")
                 .page(params[:page]).per(30)
      end

      def show
        authorize @item
        @transactions = @item.inventory_transactions.order(created_at: :desc).limit(20)
      end

      # PATCH /portal/warehouse/inventory_items/:id/adjust
      def adjust
        authorize @item, :update?

        delta = params[:delta].to_i
        if delta == 0
          redirect_to portal_warehouse_inventory_item_path(@item), alert: "Adjustment quantity cannot be zero."
          return
        end

        new_qty = @item.quantity_on_hand + delta
        if new_qty < 0
          redirect_to portal_warehouse_inventory_item_path(@item),
                      alert: "Cannot reduce below 0 (current: #{@item.quantity_on_hand})."
          return
        end

        old_qty = @item.quantity_on_hand
        @item.update!(quantity_on_hand: new_qty)
        @item.inventory_transactions.create!(
          account:          Current.account,
          transaction_type: :adjustment,
          direction:        delta > 0 ? :in : :out,
          quantity_before:  old_qty,
          quantity_change:  delta,
          quantity_after:   new_qty,
          performed_at:     Time.current,
          performed_by:     current_user,
          source:           "portal",
          notes:            params[:note].presence || "Manual adjustment"
        )

        redirect_to portal_warehouse_inventory_item_path(@item),
                    notice: "Stock adjusted by #{delta > 0 ? '+' : ''}#{delta}. New on-hand: #{new_qty}."
      rescue ActiveRecord::RecordInvalid => e
        redirect_to portal_warehouse_inventory_item_path(@item), alert: e.message
      end

      private

      def require_warehouse_access
        unless Current.role.in?(%w[owner admin manager warehouse_staff])
          redirect_to portal_root_path, alert: "Access denied."
        end
      end

      def find_item
        @item = InventoryItem.joins(:warehouse)
                             .where(warehouses: { account_id: Current.account.id })
                             .find(params[:id])
      end

      def find_scoped_warehouse
        return nil unless params[:warehouse_id].present?
        Current.account.warehouses.kept.find(params[:warehouse_id])
      end
    end
  end
end
