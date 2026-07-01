# SubscriptionPlans — the plan catalogue (Free, Silver, Gold, Platinum).
#
# plan_type enum: 0=free, 1=paid
# priority — higher priority = earlier notification delivery to matching accounts.
#   Free=0, Silver=10, Gold=20, Platinum=30
#
# monthly_price / yearly_price — stored on the plan for display; actual billing
#   amount is on AccountSubscription.current_price to allow grandfathering.
#
# metadata JSONB — provider-specific plan IDs, e.g.:
#   { "stripe_price_id_monthly": "price_xxx", "stripe_price_id_yearly": "price_yyy" }
class CreateSubscriptionPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :subscription_plans do |t|
      t.string  :name,           null: false
      t.string  :slug,           null: false
      t.text    :description
      t.integer :plan_type,      null: false, default: 0
      t.decimal :monthly_price,  null: false, default: 0, precision: 10, scale: 2
      t.decimal :yearly_price,   null: false, default: 0, precision: 10, scale: 2
      t.string  :currency,       null: false, default: "USD", limit: 3
      t.integer :priority,       null: false, default: 0
      t.boolean :active,         null: false, default: true
      t.boolean :trial_eligible, null: false, default: false
      t.integer :trial_days,     null: false, default: 0
      t.jsonb   :metadata,       null: false, default: {}
      t.timestamps
    end

    add_index :subscription_plans, :slug,     unique: true
    add_index :subscription_plans, :active,   name: "index_subscription_plans_on_active"
    add_index :subscription_plans, :priority, name: "index_subscription_plans_on_priority"

    add_check_constraint :subscription_plans, "monthly_price >= 0",
                         name: "chk_subscription_plans_monthly_price"
    add_check_constraint :subscription_plans, "yearly_price >= 0",
                         name: "chk_subscription_plans_yearly_price"
    add_check_constraint :subscription_plans, "priority >= 0",
                         name: "chk_subscription_plans_priority"
    add_check_constraint :subscription_plans, "trial_days >= 0",
                         name: "chk_subscription_plans_trial_days"
    add_check_constraint :subscription_plans, "currency ~ '^[A-Z]{3}$'",
                         name: "chk_subscription_plans_currency"
  end
end
