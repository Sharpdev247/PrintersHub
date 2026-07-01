# A user can own multiple companies (sole trader + incorporated entity, etc.).
# verified/verified_at are set by admin — default false prevents accidental approval.
class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      # Restrict delete: you cannot delete a user who still owns companies
      t.references :user, null: false, foreign_key: { on_delete: :restrict }

      t.string  :name,         null: false
      # slug is unique globally — two companies cannot share a URL identifier
      t.string  :slug,         null: false
      t.string  :email
      t.string  :phone
      t.string  :website
      t.text    :description
      t.string  :tax_number

      # Integer enum mapped in the model: 0=individual 1=partnership 2=llc 3=corporation 4=other
      t.integer :company_type, null: false, default: 0

      # Verified defaults false — admin must explicitly approve
      t.boolean  :verified,    null: false, default: false
      t.datetime :verified_at

      t.timestamps
    end

    add_index :companies, :slug, unique: true
    # Partial index: fast lookup of verified companies only
    add_index :companies, :verified, where: "verified = true", name: "index_companies_on_verified_true"

    # DB-level guard: verified_at must be null when not verified
    add_check_constraint :companies,
      "(verified = false AND verified_at IS NULL) OR (verified = true AND verified_at IS NOT NULL)",
      name: "chk_companies_verified_at_consistency"
  end
end
