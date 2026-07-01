ActiveAdmin.register Product do
  permit_params :account_id, :brand_id, :category_id, :printer_model_id,
                :name, :sku, :barcode, :barcode_type, :description,
                :status, :base_cost, :cost_currency, :weight, :weight_unit,
                :length, :width, :height, :dimension_unit,
                :has_variants, :track_inventory

  filter :account
  filter :brand
  filter :category
  filter :name
  filter :sku
  filter :status, as: :select, collection: Product.statuses
  filter :track_inventory
  filter :has_variants

  index do
    selectable_column
    id_column
    column :account
    column :name
    column :sku
    column :status
    column :base_cost
    column :track_inventory
    column("On Hand") { |p| p.total_on_hand }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :account
      row :brand
      row :category
      row :printer_model
      row :name
      row :sku
      row :barcode
      row :barcode_type
      row :status
      row :base_cost
      row :cost_currency
      row :weight
      row :weight_unit
      row :has_variants
      row :track_inventory
      row :created_at
      row :updated_at
    end

    panel "Variants" do
      table_for resource.product_variants.kept.ordered do
        column :name
        column :variant_sku
        column :display_options
        column :cost_override
        column :active
      end
    end

    panel "Inventory by Warehouse" do
      table_for resource.inventory_items.includes(:warehouse) do
        column :warehouse
        column :quantity_on_hand
        column :reserved_quantity
        column("Available") { |i| i.available_quantity }
        column :location_code
      end
    end
  end

  form do |f|
    f.inputs "Product" do
      f.input :account
      f.input :brand
      f.input :category
      f.input :printer_model
      f.input :name
      f.input :sku
      f.input :barcode
      f.input :barcode_type, as: :select, collection: %w[EAN13 EAN8 UPC ISBN QR CODE128 CODE39]
      f.input :description
      f.input :status, as: :select, collection: Product.statuses.keys
      f.input :base_cost
      f.input :cost_currency
      f.input :weight
      f.input :weight_unit, as: :select, collection: %w[kg lb oz g]
      f.input :dimension_unit, as: :select, collection: %w[cm in mm]
      f.input :has_variants
      f.input :track_inventory
    end
    f.actions
  end
end
