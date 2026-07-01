# Carts — the shopping cart for a buying Account.
# One active (status=0) cart per account enforced by partial unique index.
# status: 0=active, 1=abandoned, 2=checked_out, 3=merged
# FK: account → CASCADE (cart belongs to account; account deletion cascades)
# FK: created_by (User) → CASCADE
class CreateCarts < ActiveRecord::Migration[8.1]
  def change
    create_table :carts do |t|
      t.references :account,    null: false, foreign_key: { on_delete: :cascade }
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.integer  :status,     null: false, default: 0
      t.string   :currency,   null: false, default: "USD", limit: 3
      t.datetime :expires_at
      t.text     :notes
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :carts, :account_id,
              unique: true,
              where: "status = 0 AND discarded_at IS NULL",
              name: "index_carts_one_active_per_account"
    add_index :carts, :status, name: "index_carts_on_status"
    add_index :carts, :expires_at,
              where: "expires_at IS NOT NULL",
              name: "index_carts_on_expires_at"
    add_index :carts, :discarded_at,
              where: "discarded_at IS NOT NULL",
              name: "index_carts_on_discarded_at"

    add_check_constraint :carts, "currency ~ '^[A-Z]{3}$'", name: "chk_carts_currency"
  end
end
