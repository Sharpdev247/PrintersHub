# Links invoices to the subscription and plan that generated them.
#
# account_subscription_id — which subscription triggered this invoice
# subscription_plan_id    — snapshot of the plan at billing time
#
# Both nullable: invoices can be created manually outside of subscription billing.
#
# FK strategies:
#   account_subscription → NULLIFY : if subscription is removed, invoice persists
#   subscription_plan    → NULLIFY : if plan is deleted, invoice is preserved
class AddAccountToPlanToInvoice < ActiveRecord::Migration[8.1]
  def change
    add_column :invoices, :account_subscription_id, :bigint
    add_column :invoices, :subscription_plan_id,    :bigint

    add_foreign_key :invoices, :account_subscriptions,
                    column: :account_subscription_id,
                    on_delete: :nullify

    add_foreign_key :invoices, :subscription_plans,
                    column: :subscription_plan_id,
                    on_delete: :nullify

    add_index :invoices, :account_subscription_id,
              where: "account_subscription_id IS NOT NULL",
              name: "index_invoices_on_account_subscription_id"
  end
end
