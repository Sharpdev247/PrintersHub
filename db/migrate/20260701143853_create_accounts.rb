# Accounts — the SaaS tenant boundary. Every billing, subscription, and organizational
# entity is scoped to an Account. An Account represents an individual, company, dealer,
# vendor, or enterprise customer on PrintersHub.
#
# account_type enum: 0=individual, 1=company, 2=dealer, 3=vendor, 4=enterprise
# status enum:       0=active, 1=suspended, 2=closed
#
# provider_customer_id — future: Stripe/Paddle customer ID for billing integration
# settings JSONB — tenant-specific configuration without schema changes
# discarded_at — soft delete via the discard gem
# FriendlyId slug for SEO-friendly account URLs
class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string  :name,                 null: false
      t.string  :slug,                 null: false
      t.integer :account_type,         null: false, default: 0
      t.integer :status,               null: false, default: 0
      t.text    :bio
      t.string  :website,              limit: 255
      t.string  :phone,                limit: 30
      t.string  :email,                limit: 255
      t.boolean :verified,             null: false, default: false
      t.datetime :verified_at
      t.string  :provider_customer_id  # future: Stripe/Paddle customer
      t.jsonb   :settings,             null: false, default: {}
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :accounts, :slug,              unique: true
    add_index :accounts, :status,            name: "index_accounts_on_status"
    add_index :accounts, :account_type,      name: "index_accounts_on_account_type"
    add_index :accounts, :verified,          name: "index_accounts_on_verified"
    add_index :accounts, :discarded_at,
              where: "discarded_at IS NOT NULL",
              name: "index_accounts_on_discarded_at"
    add_index :accounts, :provider_customer_id,
              where: "provider_customer_id IS NOT NULL",
              unique: true,
              name: "index_accounts_on_provider_customer_id"
    add_index :accounts, :settings, using: :gin,
              name: "index_accounts_on_settings_gin"

    add_check_constraint :accounts, "length(name) >= 2",
                         name: "chk_accounts_name_length"
  end
end
