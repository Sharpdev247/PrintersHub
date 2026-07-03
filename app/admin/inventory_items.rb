ActiveAdmin.register InventoryItem do
  menu parent: "Inventory", priority: 1, label: "Inventory Items"
  permit_params :product_variant_id, :warehouse_id, :warehouse_zone_id,
                :location_code, :reorder_point, :reorder_quantity,
                :minimum_quantity, :maximum_quantity, :unit_cost,
                :cost_currency, :allow_backorders, :active

  filter :warehouse
  filter :active
  filter :allow_backorders

  index do
    selectable_column
    id_column
    column("Variant") { |i| i.product_variant.name }
    column("Product")  { |i| i.product_variant.product.name }
    column :warehouse
    column :location_code
    column :quantity_on_hand
    column :reserved_quantity
    column("Available") { |i| i.available_quantity }
    column :allow_backorders
    column :active
    actions
  end

  show do
    attributes_table do
      row("Product")  { |i| i.product_variant.product.name }
      row :product_variant
      row :warehouse
      row :warehouse_zone
      row :location_code
      row :quantity_on_hand
      row :reserved_quantity
      row("Available") { |i| i.available_quantity }
      row :unit_cost
      row :cost_currency
      row :reorder_point
      row :reorder_quantity
      row :allow_backorders
      row :active
      row :created_at
      row :updated_at
    end

    panel "Recent Transactions" do
      table_for resource.inventory_transactions.recent.limit(20) do
        column :transaction_type
        column :direction
        column :quantity_change
        column :quantity_before
        column :quantity_after
        column :source
        column :performed_at
      end
    end

    panel "Active Reservations" do
      table_for resource.stock_reservations.active do
        column :order_item
        column :quantity
        column :status
        column :expires_at
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :product_variant
      f.input :warehouse
      f.input :warehouse_zone
      f.input :location_code
      f.input :reorder_point
      f.input :reorder_quantity
      f.input :minimum_quantity
      f.input :maximum_quantity
      f.input :unit_cost
      f.input :cost_currency
      f.input :allow_backorders
      f.input :active
    end
    f.actions
  end
end
