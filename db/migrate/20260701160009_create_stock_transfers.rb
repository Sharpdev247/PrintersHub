class CreateStockTransfers < ActiveRecord::Migration[8.1]
  def change
    create_table :stock_transfers do |t|
      t.references :account,             null: false, foreign_key: { on_delete: :restrict }
      t.references :source_warehouse,    null: false,
                   foreign_key: { to_table: :warehouses, on_delete: :restrict }
      t.references :destination_warehouse, null: false,
                   foreign_key: { to_table: :warehouses, on_delete: :restrict }
      t.string  :transfer_number, null: false, limit: 50
      t.integer :status,          null: false, default: 0
      t.text    :notes
      t.bigint  :created_by_id
      t.bigint  :approved_by_id
      t.datetime :requested_at,   null: false
      t.datetime :approved_at
      t.datetime :shipped_at
      t.datetime :received_at
      t.timestamps
    end

    add_index :stock_transfers, :transfer_number, unique: true,
              name: "index_stock_transfers_on_transfer_number"
    add_index :stock_transfers, :status,
              name: "index_stock_transfers_on_status"
    add_index :stock_transfers, [:account_id, :status],
              name: "index_stock_transfers_on_account_status"

    add_check_constraint :stock_transfers,
                         "source_warehouse_id != destination_warehouse_id",
                         name: "chk_stock_transfers_different_warehouses"
    add_check_constraint :stock_transfers,
                         "status IN (0,1,2,3,4,5)",
                         name: "chk_stock_transfers_status"
  end
end
