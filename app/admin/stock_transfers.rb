ActiveAdmin.register StockTransfer do
  permit_params :account_id, :source_warehouse_id, :destination_warehouse_id,
                :notes, :requested_at

  filter :account
  filter :status, as: :select, collection: StockTransfer.statuses
  filter :transfer_number

  index do
    selectable_column
    id_column
    column :transfer_number
    column :account
    column :source_warehouse
    column :destination_warehouse
    column :status
    column :requested_at
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :transfer_number
      row :account
      row :source_warehouse
      row :destination_warehouse
      row :status
      row :notes
      row :requested_at
      row :approved_at
      row :shipped_at
      row :received_at
      row :created_at
      row :updated_at
    end

    panel "Transfer Items" do
      table_for resource.stock_transfer_items.includes(:inventory_item) do
        column :inventory_item
        column :quantity_requested
        column :quantity_shipped
        column :quantity_received
        column("Variance") { |i| i.variance }
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :account
      f.input :source_warehouse
      f.input :destination_warehouse
      f.input :requested_at, as: :datetime_picker
      f.input :notes
    end
    f.actions
  end
end
