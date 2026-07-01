ActiveAdmin.register Role do
  menu priority: 3, label: "Roles"

  # Explicit allowlist — slug is writable so admins can override the auto-generated value
  permit_params :name, :description

  # Scopes give one-click filtering in the index toolbar
  scope :all, default: true
  scope("With Users") { |r| r.joins(:user_roles).distinct }

  filter :name
  filter :slug
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column :slug
    column("Users") { |role| role.users.count }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :slug
      row :description
      row("Users") { |role| role.users.count }
      row :created_at
      row :updated_at
    end

    panel "Users with this Role" do
      table_for role.users do
        column :email
        column :created_at
        column("") { |u| link_to "View", admin_user_path(u) }
      end
    end
  end

  form do |f|
    f.inputs "Role Details" do
      # name is downcased before_validation — show the note to the admin
      f.input :name, hint: "Lowercase. Slug is auto-generated from name on create."
      f.input :description
    end
    f.actions
  end

  # Default sort: alphabetical by name
  config.sort_order = "name_asc"
end
