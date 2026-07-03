ActiveAdmin.register PlanFeature do
  menu priority: 11, label: "Plan Features"

  FEATURE_KEYS = %w[
    max_listings featured_listings max_team_members api_access analytics
    crm_module warehouse_module repair_module priority_notifications storage_gb
    max_api_requests_per_day messages_per_day support_level
  ].freeze

  permit_params :subscription_plan_id, :feature_key, :feature_type, :value

  # ── Filters ─────────────────────────────────────────────────────────────────
  filter :subscription_plan, as: :select,
         collection: -> { SubscriptionPlan.order(:name).map { |p| [ p.name, p.id ] } }
  filter :feature_key, as: :select,
         collection: FEATURE_KEYS.map { |k| [ k.humanize, k ] }
  filter :feature_type, as: :select,
         collection: %w[boolean limit string].map { |t| [ t.humanize, t ] }
  filter :created_at

  # ── Index ───────────────────────────────────────────────────────────────────
  index do
    selectable_column
    id_column
    column :subscription_plan do |pf|
      if pf.subscription_plan
        link_to pf.subscription_plan.name, admin_subscription_plan_path(pf.subscription_plan)
      else
        pf.subscription_plan_id
      end
    end
    column :feature_key
    column :feature_type
    column :value
    column :created_at
    actions
  end

  # ── Show ────────────────────────────────────────────────────────────────────
  show do
    attributes_table do
      row :id
      row :subscription_plan do |pf|
        if pf.subscription_plan
          link_to pf.subscription_plan.name, admin_subscription_plan_path(pf.subscription_plan)
        end
      end
      row :feature_key
      row :feature_type
      row :value
      row :created_at
      row :updated_at
    end
  end

  # ── Form ────────────────────────────────────────────────────────────────────
  form do |f|
    f.inputs "Plan Feature" do
      f.input :subscription_plan, as: :select,
              collection: SubscriptionPlan.order(:name).map { |p| [ p.name, p.id ] },
              include_blank: false
      f.input :feature_key, as: :select,
              collection: FEATURE_KEYS.map { |k| [ k.humanize, k ] },
              include_blank: false
      f.input :feature_type, as: :select,
              collection: %w[boolean limit string].map { |t| [ t.humanize, t ] },
              include_blank: false
      f.input :value, hint: "e.g. true/false for boolean, a number for limit, or text for string"
    end

    f.actions
  end

  config.sort_order = "created_at_desc"
end
