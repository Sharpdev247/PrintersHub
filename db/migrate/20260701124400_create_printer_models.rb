# brand FK is required and restricts deletion — you cannot delete HP if HP LaserJet exists.
# category FK is optional (nullable) — not every model maps to a category at creation time.
class CreatePrinterModels < ActiveRecord::Migration[8.1]
  def change
    create_table :printer_models do |t|
      t.references :brand,    null: false, foreign_key: { on_delete: :restrict }
      # Nullable FK — category can be assigned later; use :nullify so category deletion
      # does not cascade-delete the printer model, it just clears the FK.
      t.bigint :category_id

      t.string  :name,         null: false
      t.string  :slug,         null: false
      t.string  :model_number
      t.text    :description
      t.integer :release_year
      t.boolean :discontinued, null: false, default: false

      t.timestamps
    end

    add_index :printer_models, :slug,        unique: true
    add_index :printer_models, :category_id, where: "category_id IS NOT NULL"
    add_index :printer_models, :discontinued
    add_index :printer_models, [ :brand_id, :name ], unique: true,
              name: "index_printer_models_on_brand_and_name"

    # category FK added separately so we can specify on_delete: :nullify
    add_foreign_key :printer_models, :categories, column: :category_id, on_delete: :nullify
  end
end
