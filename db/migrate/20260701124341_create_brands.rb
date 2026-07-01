class CreateBrands < ActiveRecord::Migration[8.1]
  def change
    create_table :brands do |t|
      t.string  :name,        null: false
      t.string  :slug,        null: false
      t.text    :description
      t.string  :website
      # Soft-disable rather than delete — printer models reference brands
      t.boolean :active,      null: false, default: true

      t.timestamps
    end

    add_index :brands, :name, unique: true
    add_index :brands, :slug, unique: true
    add_index :brands, :active
  end
end
