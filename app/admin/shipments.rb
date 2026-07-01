ActiveAdmin.register Shipment do
  permit_params :order_id, :account_id, :tracking_number, :carrier, :status,
                :weight, :weight_unit, :shipping_cost, :currency,
                :notes, :shipped_at, :estimated_delivery_at, :delivered_at

  scope :all
  scope("Active")    { |s| s.active }
  scope("Delivered") { |s| s.status_delivered }
  scope("Returned")  { |s| s.status_returned }

  filter :tracking_number
  filter :carrier
  filter :status, as: :select, collection: Shipment.statuses.keys.map { |s| [s.humanize, s] }
  filter :account, as: :select, collection: -> { Account.order(:name).pluck(:name, :id) }
  filter :shipped_at
  filter :delivered_at
  filter :created_at

  index do
    selectable_column
    id_column
    column :order do |s|
      link_to s.order.order_number, admin_order_path(s.order) if s.order
    end
    column :account do |s|
      link_to s.account.name, admin_account_path(s.account) if s.account
    end
    column :tracking_number
    column :carrier
    column :status do |s|
      status_tag s.status.humanize,
                 class: s.status_delivered? ? "green" : (s.status_returned? || s.status_exception? ? "red" : "orange")
    end
    column :shipped_at
    column :delivered_at
    actions
  end

  show do
    attributes_table do
      row :id
      row(:order) do |s|
        link_to s.order&.order_number, admin_order_path(s.order) if s.order
      end
      row(:account) do |s|
        link_to s.account&.name, admin_account_path(s.account) if s.account
      end
      row :tracking_number
      row :carrier
      row(:status) { |s| status_tag s.status.humanize }
      row :weight
      row :weight_unit
      row(:shipping_cost) do |s|
        number_to_currency(s.shipping_cost, unit: (s.currency || "USD") + " ") if s.shipping_cost
      end
      row :currency
      row :notes
      row :shipped_at
      row :estimated_delivery_at
      row :delivered_at
      row :created_at
    end

    panel "Shipment Items" do
      table_for shipment.shipment_items do
        column :order_item do |si|
          si.order_item&.listing_snapshot&.dig("title") || si.order_item&.listing&.title
        end
        column :quantity
      end
    end
  end

  form do |f|
    f.inputs "Shipment Details" do
      f.input :order,         as: :select, collection: Order.recent.limit(200).map { |o| [o.order_number, o.id] }
      f.input :account,       as: :select, collection: Account.order(:name).map { |a| [a.name, a.id] }
      f.input :tracking_number
      f.input :carrier
      f.input :status,        as: :select, collection: Shipment.statuses.keys.map { |s| [s.humanize, s] }
      f.input :weight
      f.input :weight_unit,   as: :select, collection: Shipment::WEIGHT_UNITS
      f.input :shipping_cost
      f.input :currency
    end
    f.inputs "Dates" do
      f.input :shipped_at,             as: :datetime_picker
      f.input :estimated_delivery_at,  as: :datetime_picker
      f.input :delivered_at,           as: :datetime_picker
    end
    f.inputs "Notes" do
      f.input :notes
    end
    f.actions
  end
end
