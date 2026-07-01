# Optionally restricts a coupon to a specific subscription plan.
# Nullable: a coupon with subscription_plan_id = nil applies to any plan.
# FK NULLIFY: if the plan is deleted, the coupon becomes plan-unrestricted.
class AddSubscriptionPlanToCoupons < ActiveRecord::Migration[8.1]
  def change
    add_column :coupons, :subscription_plan_id, :bigint

    add_foreign_key :coupons, :subscription_plans,
                    column: :subscription_plan_id,
                    on_delete: :nullify

    add_index :coupons, :subscription_plan_id,
              where: "subscription_plan_id IS NOT NULL",
              name: "index_coupons_on_subscription_plan_id"
  end
end
