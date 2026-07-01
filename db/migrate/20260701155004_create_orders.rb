class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :order_number, null: false

      t.references :buyer_account,  null: false, foreign_key: { to_table: :accounts, on_delete: :restrict }
      t.references :seller_account, null: false, foreign_key: { to_table: :accounts, on_delete: :restrict }
      t.references :created_by,     null: false, foreign_key: { to_table: :users,    on_delete: :restrict }

      t.integer :status, null: false, default: 0

      t.decimal :subtotal,        null: false, precision: 12, scale: 2, default: "0.0"
      t.decimal :tax_amount,      null: false, precision: 12, scale: 2, default: "0.0"
      t.decimal :shipping_amount, null: false, precision: 12, scale: 2, default: "0.0"
      t.decimal :discount_amount, null: false, precision: 12, scale: 2, default: "0.0"
      t.decimal :total,           null: false, precision: 12, scale: 2, default: "0.0"
      t.string  :currency,        null: false, default: "USD", limit: 3

      t.bigint  :billing_address_id
      t.bigint  :shipping_address_id
      t.jsonb   :billing_address_snapshot
      t.jsonb   :shipping_address_snapshot

      t.text    :notes
      t.text    :internal_notes

      t.datetime :paid_at
      t.datetime :confirmed_at
      t.datetime :shipped_at
      t.datetime :delivered_at
      t.datetime :completed_at
      t.datetime :cancelled_at

      t.bigint  :cancelled_by_id
      t.text    :cancellation_reason

      t.jsonb   :metadata
      t.timestamps
    end

    add_foreign_key :orders, :addresses, column: :billing_address_id,  on_delete: :nullify
    add_foreign_key :orders, :addresses, column: :shipping_address_id, on_delete: :nullify
    add_foreign_key :orders, :users,     column: :cancelled_by_id,     on_delete: :nullify

    add_index :orders, :order_number, unique: true, name: "index_orders_on_order_number"
    add_index :orders, [:buyer_account_id,  :status], name: "index_orders_on_buyer_and_status"
    add_index :orders, [:seller_account_id, :status], name: "index_orders_on_seller_and_status"
    add_index :orders, :status,     name: "index_orders_on_status"
    add_index :orders, :created_at, name: "index_orders_on_created_at"
    add_index :orders, :paid_at,    where: "paid_at IS NOT NULL", name: "index_orders_on_paid_at"
    add_index :orders, [:billing_address_id],  where: "billing_address_id IS NOT NULL",  name: "index_orders_on_billing_address"
    add_index :orders, [:shipping_address_id], where: "shipping_address_id IS NOT NULL", name: "index_orders_on_shipping_address"

    add_check_constraint :orders, "subtotal >= 0",        name: "chk_orders_subtotal"
    add_check_constraint :orders, "tax_amount >= 0",      name: "chk_orders_tax_amount"
    add_check_constraint :orders, "shipping_amount >= 0", name: "chk_orders_shipping_amount"
    add_check_constraint :orders, "discount_amount >= 0", name: "chk_orders_discount_amount"
    add_check_constraint :orders, "total >= 0",           name: "chk_orders_total"
    add_check_constraint :orders, "currency ~ '^[A-Z]{3}$'", name: "chk_orders_currency"
    add_check_constraint :orders, "buyer_account_id != seller_account_id",
                         name: "chk_orders_buyer_seller_different"
  end
end
