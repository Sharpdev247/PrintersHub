class AddRoleAndNotesToAdminUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :admin_users, :role,        :string,  null: false, default: "staff"
    add_column :admin_users, :super_admin, :boolean, null: false, default: false
    add_column :admin_users, :notes,       :text
    add_column :admin_users, :active,      :boolean, null: false, default: true
    add_column :admin_users, :last_active_at, :datetime

    add_index :admin_users, :role
    add_index :admin_users, :active
  end
end
