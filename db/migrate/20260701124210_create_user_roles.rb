# Join table for the users <-> roles many-to-many relationship.
# Cascade deletes on both sides: removing a user or role cleans up the join rows.
class CreateUserRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :user_roles do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :role, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    # Composite unique index prevents a user being assigned the same role twice
    add_index :user_roles, [ :user_id, :role_id ], unique: true
  end
end
