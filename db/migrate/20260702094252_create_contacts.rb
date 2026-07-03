class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.bigint   :account_id,   null: false
      t.bigint   :owner_id
      t.string   :first_name,   null: false
      t.string   :last_name
      t.string   :email,        limit: 255
      t.string   :phone,        limit: 50
      t.string   :company_name, limit: 255
      t.string   :contact_type, limit: 20, default: "contact"
      t.string   :status,       limit: 20, default: "active"
      t.string   :source,       limit: 50
      t.text     :notes
      t.datetime :last_contacted_at
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :contacts, :account_id
    add_index :contacts, :owner_id
    add_index :contacts, :contact_type
    add_index :contacts, :status
    add_index :contacts, :discarded_at, where: "discarded_at IS NOT NULL"
    add_index :contacts, [ :account_id, :email ], unique: true,
              where: "email IS NOT NULL AND discarded_at IS NULL",
              name: "index_contacts_on_account_and_email"

    add_foreign_key :contacts, :accounts
    add_foreign_key :contacts, :users, column: :owner_id
  end
end
