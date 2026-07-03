# AccountSubscriptions — which plan an account is currently on.
#
# status enum: 0=trialing, 1=active, 2=past_due, 3=cancelled, 4=expired, 5=suspended
#
# current_price — the LOCKED price for this subscription at the time of purchase.
#   Allows grandfathering: if the plan price changes, this account keeps paying
#   what they agreed to until they change plans.
#
# billing_interval — "monthly" or "yearly". Drives invoice generation.
#
# provider_subscription_id — Stripe/Paddle external subscription ID.
# payment_provider — which gateway is processing this subscription.
#
# discarded_at — soft delete: cancelled subscriptions are kept for audit.
#
# FK strategies:
#   account            → RESTRICT : cannot delete an account with a subscription
#   subscription_plan  → RESTRICT : cannot delete a plan in use
class CreateAccountSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :account_subscriptions do |t|
      t.references :account,           null: false, foreign_key: { on_delete: :restrict }
      t.references :subscription_plan, null: false, foreign_key: { on_delete: :restrict }
      t.integer :status,               null: false, default: 0
      t.string  :billing_interval,     null: false, default: "monthly"
      t.decimal :current_price,        null: false, default: 0, precision: 10, scale: 2
      t.string  :currency,             null: false, default: "USD", limit: 3
      t.datetime :trial_ends_at
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.datetime :cancelled_at
      t.datetime :expires_at
      t.string  :provider_subscription_id
      t.string  :payment_provider
      t.jsonb   :metadata,             null: false, default: {}
      t.datetime :discarded_at
      t.timestamps
    end

    # An account should have only one active subscription at a time.
    add_index :account_subscriptions, :account_id,
              where: "status IN (0, 1, 2) AND discarded_at IS NULL",
              unique: true,
              name: "index_account_subscriptions_on_account_active"

    add_index :account_subscriptions, [ :account_id, :status ],
              name: "index_account_subscriptions_on_account_and_status"

    # Expiry sweep job: find subscriptions expiring soon.
    add_index :account_subscriptions, :expires_at,
              where: "expires_at IS NOT NULL AND status IN (0, 1)",
              name: "index_account_subscriptions_on_expires_at_active"

    add_index :account_subscriptions, :provider_subscription_id,
              where: "provider_subscription_id IS NOT NULL",
              unique: true,
              name: "index_account_subscriptions_on_provider_id"

    add_check_constraint :account_subscriptions,
                         "billing_interval IN ('monthly', 'yearly')",
                         name: "chk_account_subscriptions_billing_interval"
    add_check_constraint :account_subscriptions,
                         "current_price >= 0",
                         name: "chk_account_subscriptions_price"
    add_check_constraint :account_subscriptions,
                         "currency ~ '^[A-Z]{3}$'",
                         name: "chk_account_subscriptions_currency"
  end
end
