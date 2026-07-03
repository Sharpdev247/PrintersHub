ActiveAdmin.register Payment do
  menu parent: "Commerce", priority: 2, label: "Payments"

  permit_params :account_id, :invoice_id, :amount, :currency, :status,
                :payment_provider, :provider_payment_id, :paid_at, :failure_reason

  filter :status, as: :select, collection: Payment.statuses.keys
  filter :payment_provider
  filter :account

  scope :all, default: true
  scope("Completed") { |s| s.status_completed }
  scope("Failed")    { |s| s.status_failed }
  scope("Pending")   { |s| s.status_pending }

  index do
    selectable_column
    id_column
    column(:account) { |p| p.account ? link_to(p.account.name, admin_account_path(p.account)) : "-" }
    column("Invoice") { |p| p.invoice ? link_to(p.invoice.invoice_number, admin_invoice_path(p.invoice)) : "-" }
    column :amount
    column :currency
    column :status
    column :payment_provider
    column :paid_at
    actions
  end

  show do
    attributes_table do
      row :id
      row(:account) { |p| p.account ? link_to(p.account.name, admin_account_path(p.account)) : "-" }
      row("Invoice") { |p| p.invoice ? link_to(p.invoice.invoice_number, admin_invoice_path(p.invoice)) : "-" }
      row :amount
      row :currency
      row :status
      row :payment_provider
      row :provider_payment_id
      row :paid_at
      row :failure_reason
      row :metadata
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Payment Details" do
      f.input :account
      f.input :invoice, include_blank: true
      f.input :amount
      f.input :currency
      f.input :status, as: :select, collection: Payment.statuses.keys
      f.input :payment_provider
      f.input :provider_payment_id
      f.input :paid_at, as: :datetime_picker
      f.input :failure_reason
    end
    f.actions
  end

  config.sort_order = "created_at_desc"
end
