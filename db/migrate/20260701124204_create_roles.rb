# Roles are a controlled vocabulary (buyer, seller, dealer, etc.).
# NOT NULL + UNIQUE on both name and slug prevents duplicates at the DB level.
class CreateRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :roles do |t|
      t.string :name,        null: false
      t.string :slug,        null: false
      t.text   :description

      t.timestamps
    end

    # Unique indexes enforce business rule: role names and slugs must be distinct
    add_index :roles, :name, unique: true
    add_index :roles, :slug, unique: true
  end
end
