# ancestry stores the full parent path as "1/5/12". The ancestry gem uses this
# single column plus its index to answer ancestor/descendant queries efficiently.
class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string  :name,        null: false
      t.string  :slug,        null: false
      t.text    :description

      # ancestry gem requirement — NULL means root node, string means has parent(s)
      t.string  :ancestry

      # position allows ordered display within a level (drag-and-drop sort later)
      t.integer :position,    null: false, default: 0

      # Soft-disable categories without deleting them and breaking FKs
      t.boolean :active,      null: false, default: true

      # CSS class or icon name for frontend rendering — nullable
      t.string  :icon

      t.timestamps
    end

    add_index :categories, :slug,     unique: true
    # ancestry gem requires this index for subtree queries
    add_index :categories, :ancestry
    add_index :categories, :active
    add_index :categories, [ :ancestry, :position ], name: "index_categories_on_ancestry_position"
  end
end
