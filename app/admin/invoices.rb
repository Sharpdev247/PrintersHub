ActiveAdmin.register Invoice do
  menu priority: 14, label: "Invoices"

  permit_params :account_id, :account_subscription_id, :subscription_plan_id,
                :invoice_number, :status, :subtotal, :tax_amount, :discount_amount,
                :total_amount, :currency, :due_date, :notes

  # ── Filters ─────────────────────────────────────────────────────────────────
  filter :invoice_number
  filter :status, as: :select,
         collection: Invoice.statuses.keys.map { |s| [s.humanize, s] }
  filter :account, as: :select,
         collection: -> { Account.order(:name).map { |a| [a.name, a.id] } }
  filter :due_date
  filter :paid_at
  filter :created_at

  # ── Index ───────────────────────────────────────────────────────────────────
  index do
    selectable_column
    id_column
    column :invoice_number do |inv|
      link_to inv.invoice_number, admin_invoice_path(inv)
    end
    column :account do |inv|
      if inv.account
        link_to inv.account.name, admin_account_path(inv.account)
      else
        inv.account_id
      end
    end
    column :status do |inv|
      classes = {
        "paid"          => "yes",
        "open"          => "orange",
        "draft"         => "no",
        "void"          => "no",
        "uncollectible" => "no"
      }
      status_tag inv.status.humanize, class: classes[inv.status] || "no"
    end
    column :total_amount do |inv|
      number_to_currency(inv.total_amount, unit: inv.currency.to_s.upcase, precision: 2) if inv.total_amount
    end
    column :due_date
    column :paid_at
    column :created_at
    actions
  end

  # ── Show ────────────────────────────────────────────────────────────────────
  show do
    attributes_table do
      row :id
      row :invoice_number
      row :account do |inv|
        link_to inv.account.name, admin_account_path(inv.account) if inv.account
      end
      row :account_subscription do |inv|
        link_to inv.account_subscription_id, admin_account_subscription_path(inv.account_subscription) if inv.account_subscription
      end
      row :subscription_plan do |inv|
        link_to inv.subscription_plan.name, admin_subscription_plan_path(inv.subscription_plan) if inv.subscription_plan
      end
      row :status do |inv|
        classes = {
          "paid"          => "yes",
          "open"          => "orange",
          "draft"         => "no",
          "void"          => "no",
          "uncollectible" => "no"
        }
        status_tag inv.status.humanize, class: classes[inv.status] || "no"
      end
      row :subtotal do |inv|
        number_to_currency(inv.subtotal, precision: 2) if inv.subtotal
      end
      row :tax_amount do |inv|
        number_to_currency(inv.tax_amount, precision: 2) if inv.tax_amount
      end
      row :discount_amount do |inv|
        number_to_currency(inv.discount_amount, precision: 2) if inv.discount_amount
      end
      row :total_amount do |inv|
        number_to_currency(inv.total_amount, unit: inv.currency.to_s.upcase, precision: 2) if inv.total_amount
      end
      row :currency
      row :due_date
      row :paid_at
      row :provider_invoice_id
      row :notes
      row :metadata do |inv|
        pre JSON.pretty_generate(inv.metadata) if inv.metadata.present?
      end
      row :created_at
      row :updated_at
    end

    panel "Invoice Items (#{invoice.invoice_items.count})" do
      table_for invoice.invoice_items.order(:id) do
        column :description
        column :quantity
        column :unit_price do |item|
          number_to_currency(item.unit_price, precision: 2) if item.unit_price
        end
        column :amount do |item|
          number_to_currency(item.amount, precision: 2) if item.amount
        end
      end
    end
  end

  # ── Form ────────────────────────────────────────────────────────────────────
  form do |f|
    f.inputs "Invoice Details" do
      f.input :account, as: :select,
              collection: Account.order(:name).map { |a| [a.name, a.id] },
              include_blank: false
      f.input :invoice_number
      f.input :status, as: :select,
              collection: Invoice.statuses.keys.map { |s| [s.humanize, s] },
              include_blank: false
      f.input :notes
    end

    f.inputs "Amounts" do
      f.input :subtotal
      f.input :tax_amount
      f.input :discount_amount
      f.input :total_amount
      f.input :currency, hint: "3-letter ISO code, e.g. USD, PKR, GBP"
    end

    f.inputs "Dates" do
      f.input :due_date, as: :datepicker
    end

    f.actions
  end

  config.sort_order = "created_at_desc"
end
