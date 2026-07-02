class CreateSystemSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :system_settings do |t|
      t.string  :key,        null: false
      t.text    :value
      t.string  :value_type, null: false, default: "string"
      t.string  :category,   null: false, default: "general"
      t.text    :description
      t.boolean :editable,   null: false, default: true

      t.timestamps null: false
    end

    add_index :system_settings, :key,      unique: true
    add_index :system_settings, :category
  end
end
