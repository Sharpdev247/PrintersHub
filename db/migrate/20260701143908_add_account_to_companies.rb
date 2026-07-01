# Migrates Company ownership from User to Account.
#
# account_id    — the Account that owns this company profile
# created_by_id — the User who originally created the company (audit trail)
#   Renamed from the implicit user_id to make the role explicit.
#
# Both columns are nullable initially to allow data migration.
# The application layer will enforce account_id presence.
#
# FK strategies:
#   account    → RESTRICT : cannot delete an account with companies
#   created_by → NULLIFY  : if creator is deleted, preserve the company
class AddAccountToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :companies, :account_id,    :bigint
    add_column :companies, :created_by_id, :bigint

    add_foreign_key :companies, :accounts, column: :account_id,    on_delete: :restrict
    add_foreign_key :companies, :users,    column: :created_by_id, on_delete: :nullify

    add_index :companies, :account_id,
              name: "index_companies_on_account_id"
    add_index :companies, :created_by_id,
              where: "created_by_id IS NOT NULL",
              name: "index_companies_on_created_by_id"
  end
end
