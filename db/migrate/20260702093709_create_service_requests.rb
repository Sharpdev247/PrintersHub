class CreateServiceRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :service_requests do |t|
      t.bigint   :account_id,          null: false
      t.bigint   :customer_account_id
      t.bigint   :assigned_to_id
      t.bigint   :printer_model_id
      t.string   :request_number,      null: false
      t.string   :status,              null: false, default: "pending", limit: 30
      t.string   :priority,            null: false, default: "normal",  limit: 20
      t.string   :title,               null: false
      t.text     :description
      t.string   :serial_number,       limit: 100
      t.string   :currency,            limit: 3,  default: "USD"
      t.decimal  :estimated_cost,      precision: 12, scale: 2
      t.decimal  :final_cost,          precision: 12, scale: 2
      t.text     :notes
      t.text     :diagnosis
      t.text     :resolution
      t.datetime :reported_at
      t.datetime :scheduled_at
      t.datetime :started_at
      t.datetime :diagnosed_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :service_requests, :account_id
    add_index :service_requests, :customer_account_id
    add_index :service_requests, :assigned_to_id
    add_index :service_requests, :status
    add_index :service_requests, :request_number, unique: true

    add_foreign_key :service_requests, :accounts
    add_foreign_key :service_requests, :accounts, column: :customer_account_id
    add_foreign_key :service_requests, :users,    column: :assigned_to_id
    add_foreign_key :service_requests, :printer_models
  end
end
