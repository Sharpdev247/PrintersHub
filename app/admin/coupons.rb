ActiveAdmin.register Coupon do
  menu parent: "Commerce", priority: 5, label: "Coupons"

  permit_params :code, :name, :discount_type, :discount_value, :currency,
                :max_redemptions, :valid_from, :valid_until, :active,
                :subscription_plan_id

  # ── Filters ─────────────────────────────────────────────────────────────────
  filter :code
  filter :name
  filter :discount_type, as: :select,
         collection: Coupon.discount_types.keys.map { |t| [ t.humanize, t ] }
  filter :active, as: :boolean
  filter :created_at

  # ── Index ───────────────────────────────────────────────────────────────────
  index do
    selectable_column
    id_column
    column :code do |c|
      link_to c.code, admin_coupon_path(c)
    end
    column :name
    column :discount_type do |c|
      c.discount_type.humanize
    end
    column :discount_value do |c|
      case c.discount_type
      when "percentage"      then "#{c.discount_value}%"
      when "fixed_amount"    then number_to_currency(c.discount_value, precision: 2)
      when "free_trial_days" then "#{c.discount_value} days"
      else c.discount_value
      end
    end
    column :redemptions_count
    column :max_redemptions
    column :active do |c|
      status_tag c.active? ? "Yes" : "No", class: c.active? ? "yes" : "no"
    end
    column :valid_until
    column :created_at
    actions
  end

  # ── Show ────────────────────────────────────────────────────────────────────
  show do
    attributes_table do
      row :id
      row :code
      row :name
      row :discount_type do |c| c.discount_type.humanize end
      row :discount_value
      row :currency
      row :max_redemptions
      row :redemptions_count
      row :valid_from
      row :valid_until
      row :active do |c|
        status_tag c.active? ? "Yes" : "No", class: c.active? ? "yes" : "no"
      end
      row :subscription_plan do |c|
        link_to c.subscription_plan.name, admin_subscription_plan_path(c.subscription_plan) if c.subscription_plan
      end
      row :created_at
      row :updated_at
    end
  end

  # ── Form ────────────────────────────────────────────────────────────────────
  form do |f|
    f.inputs "Coupon Details" do
      f.input :code,  hint: "Unique redemption code (e.g. SAVE20)"
      f.input :name,  hint: "Internal label for this coupon"
      f.input :discount_type, as: :select,
              collection: Coupon.discount_types.keys.map { |t| [ t.humanize, t ] },
              include_blank: false
      f.input :discount_value, hint: "Percentage (0-100), fixed amount, or number of trial days"
      f.input :currency,       hint: "Required for fixed_amount discounts (e.g. USD)"
    end

    f.inputs "Limits & Validity" do
      f.input :max_redemptions, hint: "Leave blank for unlimited"
      f.input :valid_from,  as: :datetime_picker
      f.input :valid_until, as: :datetime_picker
      f.input :active
    end

    f.inputs "Plan Restriction (optional)" do
      f.input :subscription_plan, as: :select,
              collection: SubscriptionPlan.order(:name).map { |p| [ p.name, p.id ] },
              include_blank: true,
              hint: "Leave blank to allow on any plan"
    end

    f.actions
  end

  # ── Member Actions ──────────────────────────────────────────────────────────
  member_action :deactivate, method: :put do
    resource.update!(active: false)
    redirect_to admin_coupon_path(resource), notice: "Coupon deactivated."
  end

  # ── Action Items ────────────────────────────────────────────────────────────
  action_item :deactivate, only: :show, if: -> { resource.active? } do
    link_to "Deactivate", deactivate_admin_coupon_path(resource), method: :put,
            data: { confirm: "Deactivate this coupon? It will no longer be usable." }
  end

  config.sort_order = "created_at_desc"
end
