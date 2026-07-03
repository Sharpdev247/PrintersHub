# PaymentTransaction — one row per gateway API call on a Payment.
# The gateway_response stores the raw response JSON.
# gateway_transaction_id: partial unique index (one per gateway where present).
# status: 0=pending, 1=success, 2=failed, 3=cancelled
class CreatePaymentTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_transactions do |t|
      t.references :payment, null: false, foreign_key: { on_delete: :cascade }
      t.string  :transaction_type,       null: false, limit: 30
      t.string  :gateway,                null: false, limit: 50
      t.string  :gateway_transaction_id, limit: 255
      t.integer :status,                 null: false, default: 0
      t.decimal :amount,                 null: false, precision: 12, scale: 2
      t.string  :currency,               null: false, default: "USD", limit: 3
      t.jsonb   :gateway_response
      t.text    :gateway_message
      t.datetime :processed_at
      t.timestamps
    end

    add_index :payment_transactions,
              [ :gateway, :gateway_transaction_id ],
              unique: true,
              where: "gateway_transaction_id IS NOT NULL",
              name: "index_payment_transactions_on_gateway_txn_id"
    add_index :payment_transactions, :status, name: "index_payment_transactions_on_status"
    # t.references :payment above already creates index_payment_transactions_on_payment_id

    add_check_constraint :payment_transactions, "amount > 0",
                         name: "chk_payment_transactions_amount"
    add_check_constraint :payment_transactions,
                         "currency ~ '^[A-Z]{3}$'",
                         name: "chk_payment_transactions_currency"
    add_check_constraint :payment_transactions,
                         "transaction_type IN ('charge', 'authorize', 'capture', 'refund', 'void')",
                         name: "chk_payment_transactions_type"
  end
end
