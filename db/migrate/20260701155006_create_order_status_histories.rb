# Append-only audit log of every order status change.
# No updated_at — this table is write-once.
# source: 'system', 'user', 'webhook', 'admin'
class CreateOrderStatusHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :order_status_histories do |t|
      t.references :order,      null: false, foreign_key: { on_delete: :cascade }
      t.references :changed_by, null: true,  foreign_key: { to_table: :users, on_delete: :nullify }
      t.integer :from_status
      t.integer :to_status, null: false
      t.text    :note
      t.string  :source, null: false, default: "system", limit: 50
      t.datetime :created_at, null: false
    end

    add_index :order_status_histories, [:order_id, :created_at],
              name: "index_order_status_histories_on_order_and_time"

    add_check_constraint :order_status_histories,
                         "source IN ('system', 'user', 'webhook', 'admin')",
                         name: "chk_order_status_histories_source"
  end
end
