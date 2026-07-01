# Extend existing payments table for commerce order payments.
# payment_context: 0=subscription, 1=order
# order_id: nullable FK (only set for order payments)
class AddCommerceToPayments < ActiveRecord::Migration[8.1]
  def change
    add_reference :payments, :order, null: true,
                  foreign_key: { to_table: :orders, on_delete: :nullify }
    add_column :payments, :payment_context, :integer, null: false, default: 0

    add_index :payments, :payment_context, name: "index_payments_on_payment_context"
    # add_reference :order above auto-creates index_payments_on_order_id
  end
end
