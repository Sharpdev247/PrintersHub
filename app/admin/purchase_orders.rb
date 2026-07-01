ActiveAdmin.register PurchaseOrder do
  permit_params :account_id, :supplier_id, :warehouse_id, :status,
                :currency, :payment_terms, :notes, :internal_notes,
                :expected_at,
                purchase_order_items_attributes: [:id, :product_variant_id,
                  :quantity_ordered, :unit_cost, :notes, :_destroy]

  filter :account
  filter :supplier
  filter :warehouse
  filter :status, as: :select, collection: PurchaseOrder.statuses
  filter :po_number
  filter :currency

  index do
    selectable_column
    id_column
    column :po_number
    column :account
    column :supplier
    column :warehouse
    column :status
    column :total_amount
    column :currency
    column :expected_at
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :po_number
      row :account
      row :supplier
      row :warehouse
      row :status
      row :subtotal
      row :tax_amount
      row :shipping_cost
      row :total_amount
      row :currency
      row :payment_terms
      row :expected_at
      row :submitted_at
      row :approved_at
      row :received_at
      row :notes
      row :internal_notes
      row :created_at
      row :updated_at
    end

    panel "Line Items" do
      table_for resource.purchase_order_items.includes(:product_variant) do
        column :product_variant
        column :quantity_ordered
        column :quantity_received
        column("Remaining") { |i| i.remaining_quantity }
        column :unit_cost
        column :total_cost
      end
    end
  end

  action_item :submit, only: :show, if: -> { resource.status_draft? } do
    link_to "Submit PO", submit_admin_purchase_order_path(resource), method: :put
  end

  member_action :submit, method: :put do
    resource.submit!
    redirect_to admin_purchase_order_path(resource), notice: "Purchase Order submitted."
  end

  form do |f|
    f.inputs "Purchase Order" do
      f.input :account
      f.input :supplier
      f.input :warehouse
      f.input :currency
      f.input :payment_terms
      f.input :expected_at, as: :datetime_picker
      f.input :notes
      f.input :internal_notes
    end

    f.inputs "Line Items" do
      f.has_many :purchase_order_items, allow_destroy: true, new_record: true do |poi|
        poi.input :product_variant
        poi.input :quantity_ordered
        poi.input :unit_cost
        poi.input :notes
      end
    end

    f.actions
  end
end
