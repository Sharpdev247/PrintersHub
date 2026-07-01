class CreateInventoryTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_transactions do |t|
      t.references :inventory_item, null: false, foreign_key: { on_delete: :restrict }
      t.references :account,        null: false, foreign_key: { on_delete: :restrict }
      t.integer :transaction_type,  null: false
      t.integer :direction,         null: false
      t.integer :quantity_change,   null: false
      t.integer :quantity_before,   null: false
      t.integer :quantity_after,    null: false
      t.decimal :unit_cost,         precision: 12, scale: 2
      t.string  :reference_type,    limit: 50
      t.bigint  :reference_id
      t.string  :lot_number,        limit: 100
      t.string  :serial_number,     limit: 100
      t.text    :notes
      t.string  :source,            null: false, default: "system", limit: 30
      t.bigint  :performed_by_id
      t.datetime :performed_at,     null: false
      # No updated_at — this table is append-only
      t.datetime :created_at, null: false
    end

    add_index :inventory_transactions, [:reference_type, :reference_id],
              name: "index_inventory_transactions_on_reference"
    add_index :inventory_transactions, :transaction_type,
              name: "index_inventory_transactions_on_type"
    add_index :inventory_transactions, :performed_at,
              name: "index_inventory_transactions_on_performed_at"
    add_index :inventory_transactions, :lot_number,
              where: "lot_number IS NOT NULL",
              name: "index_inventory_transactions_on_lot_number"

    add_check_constraint :inventory_transactions,
                         "quantity_change != 0",
                         name: "chk_inventory_transactions_nonzero"
    add_check_constraint :inventory_transactions,
                         "direction IN (0, 1, 2)",
                         name: "chk_inventory_transactions_direction"
    add_check_constraint :inventory_transactions,
                         "transaction_type IN (0,1,2,3,4,5,6,7,8,9,10)",
                         name: "chk_inventory_transactions_type"
    add_check_constraint :inventory_transactions,
                         "source IN ('system','user','webhook','admin','import')",
                         name: "chk_inventory_transactions_source"
    add_check_constraint :inventory_transactions,
                         "quantity_before + quantity_change = quantity_after",
                         name: "chk_inventory_transactions_ledger"
  end
end
