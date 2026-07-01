# Payments — records of money received from accounts.
#
# status enum: 0=pending, 1=completed, 2=failed, 3=refunded
#
# payment_provider — "stripe" / "paddle" / "lemon_squeezy" / "manual"
#   Stored as string for flexibility; no enum needed here.
# provider_payment_id — the external charge/payment ID for reconciliation.
# metadata JSONB — provider-specific response data (last 4 digits, receipt URL etc.)
#
# FK strategies:
#   account → RESTRICT : preserve payment history
class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :account, null: false, foreign_key: { on_delete: :restrict }
      t.integer :status,            null: false, default: 0
      t.decimal :amount,            null: false, precision: 12, scale: 2
      t.string  :currency,          null: false, default: "USD", limit: 3
      t.string  :payment_method
      t.string  :payment_provider
      t.string  :provider_payment_id
      t.text    :failure_reason
      t.datetime :paid_at
      t.jsonb   :metadata,          null: false, default: {}
      t.timestamps
    end

    add_index :payments, [:account_id, :status],
              name: "index_payments_on_account_and_status"
    add_index :payments, :provider_payment_id,
              where: "provider_payment_id IS NOT NULL",
              unique: true,
              name: "index_payments_on_provider_payment_id"
    add_index :payments, :paid_at,
              where: "paid_at IS NOT NULL",
              name: "index_payments_on_paid_at"

    add_check_constraint :payments, "amount > 0",
                         name: "chk_payments_amount"
    add_check_constraint :payments, "currency ~ '^[A-Z]{3}$'",
                         name: "chk_payments_currency"
  end
end
