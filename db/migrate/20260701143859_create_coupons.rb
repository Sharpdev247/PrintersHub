# Coupons — discount codes for subscription plans.
#
# discount_type enum: 0=percentage, 1=fixed_amount, 2=free_trial_days
#
# discount_value:
#   percentage     → 0–100 (e.g. 20.00 = 20% off)
#   fixed_amount   → monetary amount in `currency`
#   free_trial_days → number of extra trial days
#
# max_redemptions — NULL means unlimited. redemptions_count is denormalized
#   from coupon_redemptions for fast limit checks.
#
# subscription_plan_id (added via later migration) — plan restriction.
# expires_at — NULL means no expiry.
class CreateCoupons < ActiveRecord::Migration[8.1]
  def change
    create_table :coupons do |t|
      t.string  :code,               null: false
      t.string  :name,               null: false
      t.text    :description
      t.integer :discount_type,      null: false, default: 0
      t.decimal :discount_value,     null: false, precision: 10, scale: 2
      t.string  :currency,           limit: 3   # for fixed_amount type
      t.integer :max_redemptions                 # null = unlimited
      t.integer :redemptions_count,  null: false, default: 0
      t.boolean :active,             null: false, default: true
      t.datetime :expires_at
      t.timestamps
    end

    add_index :coupons, :code,   unique: true, name: "index_coupons_on_code"
    add_index :coupons, :active, name: "index_coupons_on_active"
    add_index :coupons, :expires_at,
              where: "expires_at IS NOT NULL",
              name: "index_coupons_on_expires_at"

    add_check_constraint :coupons, "discount_value > 0",
                         name: "chk_coupons_discount_value"
    add_check_constraint :coupons, "redemptions_count >= 0",
                         name: "chk_coupons_redemptions_count"
    add_check_constraint :coupons,
                         "discount_type != 0 OR (discount_value > 0 AND discount_value <= 100)",
                         name: "chk_coupons_percentage_range"
  end
end
