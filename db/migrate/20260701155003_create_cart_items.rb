# CartItems — one row per listing per cart.
# unit_price is a snapshot of listing.price at time of add.
# FK: cart → CASCADE (deleting cart removes all items)
# FK: listing → CASCADE (deleting listing removes cart item)
# FK: added_by (User) → NULLIFY
class CreateCartItems < ActiveRecord::Migration[8.1]
  def change
    create_table :cart_items do |t|
      t.references :cart,     null: false, foreign_key: { on_delete: :cascade }
      t.references :listing,  null: false, foreign_key: { on_delete: :cascade }
      t.references :added_by, null: true,  foreign_key: { to_table: :users, on_delete: :nullify }
      t.integer  :quantity,   null: false, default: 1
      t.decimal  :unit_price, null: false, precision: 12, scale: 2
      t.string   :currency,   null: false, default: "USD", limit: 3
      t.text     :notes
      t.timestamps
    end

    add_index :cart_items, [ :cart_id, :listing_id ], unique: true,
              name: "index_cart_items_on_cart_and_listing"

    add_check_constraint :cart_items, "quantity > 0",                 name: "chk_cart_items_quantity"
    add_check_constraint :cart_items, "unit_price >= 0",              name: "chk_cart_items_unit_price"
    add_check_constraint :cart_items, "currency ~ '^[A-Z]{3}$'",     name: "chk_cart_items_currency"
  end
end
