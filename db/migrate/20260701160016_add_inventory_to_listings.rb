class AddInventoryToListings < ActiveRecord::Migration[8.1]
  def change
    add_reference :listings, :product,        null: true,
                  foreign_key: { to_table: :products,         on_delete: :nullify }
    add_reference :listings, :inventory_item,  null: true,
                  foreign_key: { to_table: :inventory_items,  on_delete: :nullify }
  end
end
