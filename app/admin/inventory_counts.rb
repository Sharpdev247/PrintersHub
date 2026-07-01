ActiveAdmin.register InventoryCount do
  permit_params :account_id, :warehouse_id, :count_type, :notes

  filter :account
  filter :warehouse
  filter :status, as: :select, collection: InventoryCount.statuses
  filter :count_type, as: :select, collection: %w[full cycle spot]
  filter :count_number

  index do
    selectable_column
    id_column
    column :count_number
    column :account
    column :warehouse
    column :count_type
    column :status
    column("Progress") { |c| "#{c.progress_percentage}%" }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :count_number
      row :account
      row :warehouse
      row :count_type
      row :status
      row("Progress") { |c| "#{c.progress_percentage}%" }
      row :notes
      row :started_at
      row :completed_at
      row :approved_at
      row :created_at
    end

    panel "Count Items" do
      table_for resource.inventory_count_items.includes(:inventory_item).limit(50) do
        column :inventory_item
        column :expected_quantity
        column :actual_quantity
        column :variance
        column :counted
        column :counted_at
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :account
      f.input :warehouse
      f.input :count_type, as: :select, collection: %w[full cycle spot]
      f.input :notes
    end
    f.actions
  end
end
