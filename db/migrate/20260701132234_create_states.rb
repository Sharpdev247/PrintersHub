# States / provinces / regions within a country.
# RESTRICT on country delete: cannot delete a country that still has states.
class CreateStates < ActiveRecord::Migration[8.1]
  def change
    create_table :states do |t|
      t.references :country, null: false, foreign_key: { on_delete: :restrict }
      t.string :name, null: false
      # code is nullable — not every country assigns short codes to its states
      t.string :code, limit: 10

      t.timestamps
    end

    # "Punjab" must be unique within Pakistan — but can also exist in India
    add_index :states, [ :country_id, :name ], unique: true, name: "index_states_on_country_and_name"

    # Partial unique index: only enforces uniqueness when code is present
    add_index :states, [ :country_id, :code ],
              unique: true,
              where: "code IS NOT NULL",
              name: "index_states_on_country_and_code"

    # Fast lookup: "give me all states for country X"
    add_index :states, :name
  end
end
