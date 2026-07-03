ActiveAdmin.register PaymentTransaction do
  permit_params :payment_id, :transaction_type, :gateway, :gateway_transaction_id,
                :status, :amount, :currency, :gateway_message, :processed_at

  scope :all
  scope("Successful") { |s| s.status_success }
  scope("Failed")     { |s| s.status_failed }
  scope("Pending")    { |s| s.status_pending }
  scope("Charges")    { |s| s.charges }
  scope("Refunds")    { |s| s.refunds }

  filter :gateway
  filter :transaction_type, as: :select, collection: PaymentTransaction::TRANSACTION_TYPES.map { |t| [ t.humanize, t ] }
  filter :status, as: :select, collection: PaymentTransaction.statuses.keys.map { |s| [ s.humanize, s ] }
  filter :gateway_transaction_id
  filter :created_at

  index do
    selectable_column
    id_column
    column :payment do |pt|
      link_to "Payment ##{pt.payment_id}", admin_payment_path(pt.payment)
    end
    column :transaction_type
    column :gateway
    column :gateway_transaction_id
    column :status do |pt|
      status_tag pt.status.humanize,
                 class: pt.status_success? ? "green" : (pt.status_failed? ? "red" : "orange")
    end
    column :amount do |pt|
      number_to_currency(pt.amount, unit: pt.currency + " ")
    end
    column :currency
    column :processed_at
    actions
  end

  show do
    attributes_table do
      row :id
      row(:payment) { |pt| link_to "Payment ##{pt.payment_id}", admin_payment_path(pt.payment) }
      row :transaction_type
      row :gateway
      row :gateway_transaction_id
      row(:status) { |pt| status_tag pt.status.humanize }
      row(:amount) { |pt| number_to_currency(pt.amount, unit: pt.currency + " ") }
      row :currency
      row :gateway_message
      row :processed_at
      row :created_at
    end

    panel "Gateway Response" do
      pre do
        JSON.pretty_generate(shipment.gateway_response || {}) rescue resource.gateway_response.to_s
      end
    end
  end

  form do |f|
    f.inputs "Transaction Details" do
      f.input :payment, as: :select, collection: Payment.order(id: :desc).limit(100).map { |p| [ "Payment ##{p.id} (#{p.amount} #{p.currency})", p.id ] }
      f.input :transaction_type, as: :select, collection: PaymentTransaction::TRANSACTION_TYPES
      f.input :gateway,          as: :select, collection: PaymentTransaction::GATEWAYS
      f.input :gateway_transaction_id
      f.input :status, as: :select, collection: PaymentTransaction.statuses.keys.map { |s| [ s.humanize, s ] }
      f.input :amount
      f.input :currency
      f.input :gateway_message
      f.input :processed_at, as: :datetime_picker
    end
    f.actions
  end
end
