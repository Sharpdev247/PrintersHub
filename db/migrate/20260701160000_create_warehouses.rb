class CreateWarehouses < ActiveRecord::Migration[8.1]
  def change
    create_table :warehouses do |t|
      t.references :account, null: false, foreign_key: { on_delete: :restrict }
      t.string  :name,         null: false, limit: 255
      t.string  :code,         null: false, limit: 20
      t.string  :address_line1, limit: 255
      t.string  :address_line2, limit: 255
      t.string  :city,          limit: 100
      t.string  :state,         limit: 100
      t.string  :country_code,  limit: 2
      t.string  :postal_code,   limit: 20
      t.string  :phone,         limit: 30
      t.string  :email,         limit: 255
      t.string  :contact_name,  limit: 255
      t.boolean :is_default,    null: false, default: false
      t.boolean :active,        null: false, default: true
      t.jsonb   :metadata
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :warehouses, [ :account_id, :code ], unique: true,
              name: "index_warehouses_on_account_code"
    add_index :warehouses, :discarded_at, name: "index_warehouses_on_discarded_at"
    add_index :warehouses, [ :account_id, :is_default ],
              where: "is_default = true",
              name: "index_warehouses_one_default_per_account"
  end
end
