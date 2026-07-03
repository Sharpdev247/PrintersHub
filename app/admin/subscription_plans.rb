ActiveAdmin.register SubscriptionPlan do
  menu parent: "Subscriptions", priority: 1, label: "Subscription Plans"

  permit_params :name, :plan_type, :monthly_price, :yearly_price, :trial_days,
                :priority, :active, :description

  # ── Scopes ──────────────────────────────────────────────────────────────────
  scope :all, default: true
  scope("Active") { |s| s.active }

  # ── Filters ─────────────────────────────────────────────────────────────────
  filter :name
  filter :plan_type, as: :select,
         collection: SubscriptionPlan.plan_types.keys.map { |t| [ t.humanize, t ] }
  filter :active, as: :boolean
  filter :created_at

  # ── Index ───────────────────────────────────────────────────────────────────
  index do
    selectable_column
    id_column
    column :name do |p|
      link_to p.name, admin_subscription_plan_path(p)
    end
    column :plan_type do |p|
      p.plan_type.humanize
    end
    column :monthly_price do |p|
      number_to_currency(p.monthly_price, precision: 2) if p.monthly_price
    end
    column :yearly_price do |p|
      number_to_currency(p.yearly_price, precision: 2) if p.yearly_price
    end
    column :trial_days
    column :priority
    column :active do |p|
      status_tag p.active? ? "Yes" : "No", class: p.active? ? "yes" : "no"
    end
    column :created_at
    actions
  end

  # ── Show ────────────────────────────────────────────────────────────────────
  show do
    attributes_table do
      row :id
      row :name
      row :slug
      row :plan_type do |p| p.plan_type.humanize end
      row :monthly_price do |p|
        number_to_currency(p.monthly_price, precision: 2) if p.monthly_price
      end
      row :yearly_price do |p|
        number_to_currency(p.yearly_price, precision: 2) if p.yearly_price
      end
      row :trial_days
      row :priority
      row :active do |p|
        status_tag p.active? ? "Yes" : "No", class: p.active? ? "yes" : "no"
      end
      row :description
      row :metadata do |p|
        pre JSON.pretty_generate(p.metadata) if p.metadata.present?
      end
      row :created_at
      row :updated_at
    end

    panel "Plan Features (#{subscription_plan.plan_features.count})" do
      table_for subscription_plan.plan_features.order(:feature_key) do
        column :feature_key
        column :feature_type
        column :value
        column :created_at
      end
    end
  end

  # ── Form ────────────────────────────────────────────────────────────────────
  form do |f|
    f.inputs "Plan Details" do
      f.input :name
      f.input :plan_type, as: :select,
              collection: SubscriptionPlan.plan_types.keys.map { |t| [ t.humanize, t ] },
              include_blank: false
      f.input :description
    end

    f.inputs "Pricing" do
      f.input :monthly_price, hint: "Leave blank for free plans"
      f.input :yearly_price,  hint: "Leave blank for free plans"
      f.input :trial_days,    hint: "Number of trial days (0 for none)"
    end

    f.inputs "Settings" do
      f.input :priority, hint: "Lower number = higher priority"
      f.input :active
    end

    f.actions
  end

  config.sort_order = "priority_asc"
end
