# Links an account subscription to the coupon redemption that was applied.
# Nullable: most subscriptions have no coupon.
# FK NULLIFY: if the redemption record is removed, the subscription persists.
class AddCouponToAccountSubscription < ActiveRecord::Migration[8.1]
  def change
    add_column :account_subscriptions, :coupon_redemption_id, :bigint

    add_foreign_key :account_subscriptions, :coupon_redemptions,
                    column: :coupon_redemption_id,
                    on_delete: :nullify

    add_index :account_subscriptions, :coupon_redemption_id,
              where: "coupon_redemption_id IS NOT NULL",
              name: "index_account_subscriptions_on_coupon_redemption"
  end
end
