ActiveAdmin.register Order do
  permit_params :buyer_account_id, :seller_account_id, :created_by_id,
                :status, :currency, :subtotal, :tax_amount, :shipping_amount,
                :discount_amount, :total, :notes, :internal_notes

  scope :all
  scope("Pending Payment") { |s| s.status_pending_payment }
  scope("Processing")      { |s| s.status_processing }
  scope("Shipped")         { |s| s.status_shipped }
  scope("Delivered")       { |s| s.status_delivered }
  scope("Cancelled")       { |s| s.status_cancelled }
  scope("Completed")       { |s| s.status_completed }

  filter :order_number
  filter :status, as: :select, collection: Order.statuses.keys.map { |s| [s.humanize, s] }
  filter :buyer_account, as: :select, collection: -> { Account.order(:name).pluck(:name, :id) }
  filter :seller_account, as: :select, collection: -> { Account.order(:name).pluck(:name, :id) }
  filter :currency
  filter :paid_at
  filter :created_at

  index do
    selectable_column
    id_column
    column :order_number do |o|
      link_to o.order_number, admin_order_path(o)
    end
    column :buyer_account do |o|
      link_to o.buyer_account.name, admin_account_path(o.buyer_account) if o.buyer_account
    end
    column :seller_account do |o|
      link_to o.seller_account.name, admin_account_path(o.seller_account) if o.seller_account
    end
    column :status do |o|
      status_tag o.status.humanize,
                 class: case o.status
                        when "completed", "delivered" then "green"
                        when "cancelled", "refunded"  then "red"
                        when "shipped", "processing"  then "orange"
                        else "grey"
                        end
    end
    column :total do |o|
      number_to_currency(o.total, unit: o.currency + " ")
    end
    column :currency
    column :paid_at
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :order_number
      row(:buyer_account)  { |o| link_to o.buyer_account&.name,  admin_account_path(o.buyer_account)  if o.buyer_account }
      row(:seller_account) { |o| link_to o.seller_account&.name, admin_account_path(o.seller_account) if o.seller_account }
      row(:created_by)     { |o| o.created_by&.email }
      row(:status)         { |o| status_tag o.status.humanize }
      row(:subtotal)       { |o| number_to_currency(o.subtotal,        unit: o.currency + " ") }
      row(:tax_amount)     { |o| number_to_currency(o.tax_amount,      unit: o.currency + " ") }
      row(:shipping_amount) { |o| number_to_currency(o.shipping_amount, unit: o.currency + " ") }
      row(:discount_amount) { |o| number_to_currency(o.discount_amount, unit: o.currency + " ") }
      row(:total)          { |o| number_to_currency(o.total,           unit: o.currency + " ") }
      row :currency
      row :notes
      row :internal_notes
      row :paid_at
      row :confirmed_at
      row :shipped_at
      row :delivered_at
      row :completed_at
      row :cancelled_at
      row :cancellation_reason
      row :created_at
      row :updated_at
    end

    panel "Order Items" do
      table_for order.order_items do
        column :id
        column :listing do |oi|
          if oi.listing
            link_to oi.listing.title, admin_listing_path(oi.listing)
          elsif oi.listing_snapshot.present?
            oi.listing_snapshot["title"]
          end
        end
        column :quantity
        column :unit_price do |oi|
          number_to_currency(oi.unit_price, unit: oi.currency + " ")
        end
        column :tax_amount do |oi|
          number_to_currency(oi.tax_amount, unit: oi.currency + " ")
        end
        column :total do |oi|
          number_to_currency(oi.total, unit: oi.currency + " ")
        end
        column :currency
      end
    end

    panel "Status History" do
      table_for order.order_status_histories.order(created_at: :asc) do
        column :from_status, &:from_status_name
        column :to_status,   &:to_status_name
        column :source
        column :note
        column :changed_by do |h|
          h.changed_by&.email
        end
        column :created_at
      end
    end

    panel "Shipments" do
      table_for order.shipments do
        column :id
        column :tracking_number
        column :carrier
        column :status do |s|
          status_tag s.status.humanize
        end
        column :shipped_at
        column :delivered_at
        column :actions do |s|
          link_to "View", admin_shipment_path(s)
        end
      end
    end

    panel "Payments" do
      table_for order.payments do
        column :id
        column :amount do |p|
          number_to_currency(p.amount, unit: p.currency + " ")
        end
        column :status do |p|
          status_tag p.status.humanize
        end
        column :payment_provider
        column :paid_at
        column :actions do |p|
          link_to "View", admin_payment_path(p)
        end
      end
    end
  end

  form do |f|
    f.inputs "Order Details" do
      f.input :buyer_account,  as: :select, collection: Account.order(:name).map { |a| [a.name, a.id] }
      f.input :seller_account, as: :select, collection: Account.order(:name).map { |a| [a.name, a.id] }
      f.input :status,         as: :select, collection: Order.statuses.keys.map { |s| [s.humanize, s] }
      f.input :currency
    end
    f.inputs "Financials" do
      f.input :subtotal
      f.input :tax_amount
      f.input :shipping_amount
      f.input :discount_amount
      f.input :total
    end
    f.inputs "Notes" do
      f.input :notes
      f.input :internal_notes
    end
    f.actions
  end
end
