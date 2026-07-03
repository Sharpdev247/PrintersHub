# CouponRedemptions — tracks which accounts have used which coupons.
#
# One coupon per account (unique index) prevents abuse.
# discount_applied — snapshot of the actual discount at redemption time.
#
# FK strategies:
#   coupon  → RESTRICT : preserve redemption history
#   account → RESTRICT : preserve redemption history
class CreateCouponRedemptions < ActiveRecord::Migration[8.1]
  def change
    create_table :coupon_redemptions do |t|
      t.references :coupon,  null: false, foreign_key: { on_delete: :restrict }
      t.references :account, null: false, foreign_key: { on_delete: :restrict }
      t.decimal :discount_applied, null: false, precision: 12, scale: 2
      t.timestamps
    end

    # An account can only redeem each coupon once.
    add_index :coupon_redemptions, [ :coupon_id, :account_id ],
              unique: true,
              name: "index_coupon_redemptions_on_coupon_and_account"

    add_check_constraint :coupon_redemptions, "discount_applied > 0",
                         name: "chk_coupon_redemptions_discount"
  end
end
