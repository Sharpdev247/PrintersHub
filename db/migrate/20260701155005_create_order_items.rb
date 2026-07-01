# OrderItems — line items on an order.
# listing_id → NULLIFY (listing can be deleted after order placed; snapshot in listing_snapshot)
# seller_account_id → NULLIFY (denormalized for query convenience)
# order_id → CASCADE (deleting order cascades to items)
class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order,          null: false, foreign_key: { on_delete: :cascade }
      t.references :listing,        null: true,  foreign_key: { on_delete: :nullify }
      t.references :seller_account, null: true,  foreign_key: { to_table: :accounts, on_delete: :nullify }

      t.integer :quantity,         null: false, default: 1
      t.decimal :unit_price,       null: false, precision: 12, scale: 2
      t.decimal :tax_rate_applied, null: false, precision: 8,  scale: 6, default: "0.0"
      t.decimal :tax_amount,       null: false, precision: 12, scale: 2, default: "0.0"
      t.decimal :discount_amount,  null: false, precision: 12, scale: 2, default: "0.0"
      t.decimal :total,            null: false, precision: 12, scale: 2, default: "0.0"
      t.string  :currency,         null: false, default: "USD", limit: 3

      t.jsonb   :listing_snapshot

      t.timestamps
    end

    # t.references above already creates index_order_items_on_listing_id and
    # index_order_items_on_seller_account_id — no explicit add_index needed.

    add_check_constraint :order_items, "quantity > 0",         name: "chk_order_items_quantity"
    add_check_constraint :order_items, "unit_price >= 0",      name: "chk_order_items_unit_price"
    add_check_constraint :order_items, "tax_amount >= 0",      name: "chk_order_items_tax_amount"
    add_check_constraint :order_items, "discount_amount >= 0", name: "chk_order_items_discount"
    add_check_constraint :order_items, "total >= 0",           name: "chk_order_items_total"
    add_check_constraint :order_items, "currency ~ '^[A-Z]{3}$'", name: "chk_order_items_currency"
  end
end
