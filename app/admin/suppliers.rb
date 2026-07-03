ActiveAdmin.register Supplier do
  menu parent: "Inventory", priority: 6, label: "Suppliers"
  permit_params :account_id, :name, :code, :contact_name, :email, :phone,
                :website, :address_line1, :address_line2, :city, :state,
                :country_code, :postal_code, :currency, :payment_terms,
                :lead_time_days, :active, :notes

  filter :account
  filter :name
  filter :code
  filter :country_code
  filter :active
  filter :currency

  index do
    selectable_column
    id_column
    column :account
    column :name
    column :code
    column :currency
    column :payment_terms
    column :lead_time_days
    column :active
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :account
      row :name
      row :code
      row :contact_name
      row :email
      row :phone
      row :website
      row :address_line1
      row :city
      row :country_code
      row :currency
      row :payment_terms
      row :lead_time_days
      row :active
      row :notes
      row :created_at
      row :updated_at
    end

    panel "Purchase Orders" do
      table_for resource.purchase_orders.order(created_at: :desc).limit(20) do
        column :po_number
        column :status
        column :total_amount
        column :currency
        column :created_at
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :account
      f.input :name
      f.input :code
      f.input :contact_name
      f.input :email
      f.input :phone
      f.input :website
      f.input :address_line1
      f.input :address_line2
      f.input :city
      f.input :state
      f.input :country_code
      f.input :postal_code
      f.input :currency
      f.input :payment_terms
      f.input :lead_time_days
      f.input :active
      f.input :notes
    end
    f.actions
  end
end
