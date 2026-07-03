ActiveAdmin.register AccountSubscription do
  menu parent: "Subscriptions", priority: 3, label: "Account Subscriptions"

  permit_params :account_id, :subscription_plan_id, :coupon_redemption_id, :status,
                :billing_interval, :current_price, :currency, :starts_at, :ends_at,
                :trial_ends_at, :cancelled_at, :provider_subscription_id, :discarded_at

  # ── Filters ─────────────────────────────────────────────────────────────────
  filter :status, as: :select,
         collection: AccountSubscription.statuses.keys.map { |s| [ s.humanize, s ] }
  filter :billing_interval, as: :select,
         collection: %w[monthly yearly].map { |i| [ i.humanize, i ] }
  filter :account, as: :select,
         collection: -> { Account.order(:name).map { |a| [ a.name, a.id ] } }
  filter :subscription_plan, as: :select,
         collection: -> { SubscriptionPlan.order(:name).map { |p| [ p.name, p.id ] } }
  filter :starts_at
  filter :ends_at
  filter :created_at

  # ── Index ───────────────────────────────────────────────────────────────────
  index do
    selectable_column
    id_column
    column :account do |s|
      if s.account
        link_to s.account.name, admin_account_path(s.account)
      else
        s.account_id
      end
    end
    column :subscription_plan do |s|
      if s.subscription_plan
        link_to s.subscription_plan.name, admin_subscription_plan_path(s.subscription_plan)
      else
        s.subscription_plan_id
      end
    end
    column :status do |s|
      classes = {
        "active"    => "yes",
        "trialing"  => "orange",
        "past_due"  => "orange",
        "cancelled" => "no",
        "expired"   => "no",
        "suspended" => "no"
      }
      status_tag s.status.humanize, class: classes[s.status] || "no"
    end
    column :billing_interval
    column :starts_at
    column :ends_at
    column :created_at
    actions
  end

  # ── Show ────────────────────────────────────────────────────────────────────
  show do
    attributes_table do
      row :id
      row :account do |s|
        link_to s.account.name, admin_account_path(s.account) if s.account
      end
      row :subscription_plan do |s|
        link_to s.subscription_plan.name, admin_subscription_plan_path(s.subscription_plan) if s.subscription_plan
      end
      row :coupon_redemption
      row :status do |s|
        classes = {
          "active"    => "yes",
          "trialing"  => "orange",
          "past_due"  => "orange",
          "cancelled" => "no",
          "expired"   => "no",
          "suspended" => "no"
        }
        status_tag s.status.humanize, class: classes[s.status] || "no"
      end
      row :billing_interval
      row :current_price do |s|
        number_to_currency(s.current_price, unit: s.currency.to_s.upcase, precision: 2) if s.current_price
      end
      row :currency
      row :starts_at
      row :ends_at
      row :trial_ends_at
      row :cancelled_at
      row :provider_subscription_id
      row :discarded_at
      row :metadata do |s|
        pre JSON.pretty_generate(s.metadata) if s.metadata.present?
      end
      row :created_at
      row :updated_at
    end
  end

  # ── Form ────────────────────────────────────────────────────────────────────
  form do |f|
    f.inputs "Subscription Details" do
      f.input :account, as: :select,
              collection: Account.order(:name).map { |a| [ a.name, a.id ] },
              include_blank: false
      f.input :subscription_plan, as: :select,
              collection: SubscriptionPlan.order(:name).map { |p| [ p.name, p.id ] },
              include_blank: false
      f.input :status, as: :select,
              collection: AccountSubscription.statuses.keys.map { |s| [ s.humanize, s ] },
              include_blank: false
      f.input :billing_interval, as: :select,
              collection: %w[monthly yearly].map { |i| [ i.humanize, i ] },
              include_blank: false
    end

    f.inputs "Pricing" do
      f.input :current_price
      f.input :currency, hint: "3-letter ISO code, e.g. USD, PKR, GBP"
    end

    f.inputs "Dates" do
      f.input :starts_at,     as: :datetime_picker
      f.input :ends_at,       as: :datetime_picker
      f.input :trial_ends_at, as: :datetime_picker
    end

    f.actions
  end

  config.sort_order = "created_at_desc"
end
