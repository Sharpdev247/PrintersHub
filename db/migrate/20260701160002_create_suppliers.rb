class CreateSuppliers < ActiveRecord::Migration[8.1]
  def change
    create_table :suppliers do |t|
      t.references :account, null: false, foreign_key: { on_delete: :restrict }
      t.string  :name,          null: false, limit: 255
      t.string  :code,          null: false, limit: 30
      t.string  :contact_name,  limit: 255
      t.string  :email,         limit: 255
      t.string  :phone,         limit: 30
      t.string  :website,       limit: 255
      t.string  :address_line1, limit: 255
      t.string  :address_line2, limit: 255
      t.string  :city,          limit: 100
      t.string  :state,         limit: 100
      t.string  :country_code,  limit: 2
      t.string  :postal_code,   limit: 20
      t.string  :currency,      null: false, default: "USD", limit: 3
      t.string  :payment_terms, limit: 50, default: "NET30"
      t.integer :lead_time_days, default: 7
      t.boolean :active,        null: false, default: true
      t.text    :notes
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :suppliers, [ :account_id, :code ], unique: true,
              name: "index_suppliers_on_account_code"
    add_index :suppliers, :discarded_at, name: "index_suppliers_on_discarded_at"
    add_check_constraint :suppliers, "lead_time_days >= 0",
                         name: "chk_suppliers_lead_time"
    add_check_constraint :suppliers, "currency ~ '^[A-Z]{3}$'",
                         name: "chk_suppliers_currency"
  end
end
