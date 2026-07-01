ActiveAdmin.register Warehouse do
  permit_params :account_id, :name, :code, :address_line1, :address_line2,
                :city, :state, :country_code, :postal_code, :phone, :email,
                :contact_name, :is_default, :active

  filter :account
  filter :name
  filter :code
  filter :country_code
  filter :active
  filter :is_default

  index do
    selectable_column
    id_column
    column :account
    column :name
    column :code
    column :country_code
    column :is_default
    column :active
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :account
      row :name
      row :code
      row :address_line1
      row :address_line2
      row :city
      row :state
      row :country_code
      row :postal_code
      row :phone
      row :email
      row :contact_name
      row :is_default
      row :active
      row :created_at
      row :updated_at
    end

    panel "Warehouse Zones" do
      table_for resource.warehouse_zones do
        column :code
        column :name
        column :zone_type
        column :active
      end
    end

    panel "Inventory Items" do
      table_for resource.inventory_items.includes(:product_variant).limit(20) do
        column :product_variant
        column :location_code
        column :quantity_on_hand
        column :reserved_quantity
        column("Available") { |i| i.available_quantity }
        column :active
      end
    end
  end

  form do |f|
    f.inputs "Warehouse" do
      f.input :account
      f.input :name
      f.input :code
      f.input :address_line1
      f.input :address_line2
      f.input :city
      f.input :state
      f.input :country_code
      f.input :postal_code
      f.input :phone
      f.input :email
      f.input :contact_name
      f.input :is_default
      f.input :active
    end
    f.actions
  end
end
