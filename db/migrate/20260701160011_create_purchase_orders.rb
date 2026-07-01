class CreatePurchaseOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :purchase_orders do |t|
      t.references :account,   null: false, foreign_key: { on_delete: :restrict }
      t.references :supplier,  null: false, foreign_key: { on_delete: :restrict }
      t.references :warehouse, null: false, foreign_key: { on_delete: :restrict }
      t.string  :po_number,    null: false, limit: 50
      t.integer :status,       null: false, default: 0
      t.decimal :subtotal,     null: false, precision: 12, scale: 2, default: 0
      t.decimal :tax_amount,   null: false, precision: 12, scale: 2, default: 0
      t.decimal :shipping_cost, null: false, precision: 12, scale: 2, default: 0
      t.decimal :total_amount, null: false, precision: 12, scale: 2, default: 0
      t.string  :currency,     null: false, limit: 3, default: "USD"
      t.string  :payment_terms, limit: 50
      t.text    :notes
      t.text    :internal_notes
      t.bigint  :created_by_id
      t.bigint  :approved_by_id
      t.datetime :expected_at
      t.datetime :submitted_at
      t.datetime :approved_at
      t.datetime :received_at
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :purchase_orders, :po_number, unique: true,
              name: "index_purchase_orders_on_po_number"
    add_index :purchase_orders, :status,
              name: "index_purchase_orders_on_status"
    add_index :purchase_orders, [:account_id, :status],
              name: "index_purchase_orders_on_account_status"
    add_index :purchase_orders, :discarded_at,
              name: "index_purchase_orders_on_discarded_at"

    add_check_constraint :purchase_orders, "subtotal >= 0",
                         name: "chk_purchase_orders_subtotal"
    add_check_constraint :purchase_orders, "total_amount >= 0",
                         name: "chk_purchase_orders_total"
    add_check_constraint :purchase_orders, "currency ~ '^[A-Z]{3}$'",
                         name: "chk_purchase_orders_currency"
    add_check_constraint :purchase_orders,
                         "status IN (0,1,2,3,4,5,6)",
                         name: "chk_purchase_orders_status"
  end
end
