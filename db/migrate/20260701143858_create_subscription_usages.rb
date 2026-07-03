# SubscriptionUsages — tracks feature consumption per billing period.
#
# feature_key — same keys as PlanFeature.feature_key
# quantity    — consumed amount (decimal for storage_gb etc.)
# period_start / period_end — billing period boundaries
#
# Unique [account_id, feature_key, period_start] ensures one usage row per
# feature per period. Use upsert_all for efficient bulk updates.
#
# FK strategies:
#   account_subscription → CASCADE : clean up when subscription is removed
#   account              → CASCADE : clean up when account is removed
class CreateSubscriptionUsages < ActiveRecord::Migration[8.1]
  def change
    create_table :subscription_usages do |t|
      t.references :account_subscription, null: false, foreign_key: { on_delete: :cascade }
      t.references :account,              null: false, foreign_key: { on_delete: :cascade }
      t.string  :feature_key,  null: false
      t.decimal :quantity,     null: false, default: 0, precision: 15, scale: 3
      t.date    :period_start, null: false
      t.date    :period_end
      t.timestamps
    end

    # One usage row per feature per period per account.
    add_index :subscription_usages, [ :account_id, :feature_key, :period_start ],
              unique: true,
              name: "index_subscription_usages_on_account_feature_period"

    # Find current period's usage for an account quickly.
    add_index :subscription_usages, [ :account_id, :period_start ],
              name: "index_subscription_usages_on_account_and_period"

    add_check_constraint :subscription_usages, "quantity >= 0",
                         name: "chk_subscription_usages_quantity"
  end
end
