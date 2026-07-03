ActiveAdmin.register AdminUser do
  menu label: "Admin Users", parent: "Platform", priority: 1

  permit_params :email, :password, :password_confirmation,
                :role, :super_admin, :active, :notes

  scope :all
  scope("Active")      { |s| s.active }
  scope("Super Admin") { |s| s.super_admins }

  filter :email
  filter :role, as: :select, collection: AdminUser::ROLES.map { |r| [ r.humanize, r ] }
  filter :active
  filter :super_admin
  filter :sign_in_count
  filter :current_sign_in_at
  filter :created_at

  index do
    selectable_column
    id_column
    column :email
    column :role do |a|
      tags = [ status_tag(a.role.humanize) ]
      tags << status_tag("Super Admin", class: "orange") if a.super_admin?
      safe_join(tags, " ")
    end
    column(:active) { |a| status_tag a.active? ? "Yes" : "No", class: a.active? ? "green" : "red" }
    column :sign_in_count
    column :current_sign_in_at
    column :last_sign_in_ip
    actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row(:role)       { |a| a.role.humanize }
      row(:super_admin) { |a| status_tag a.super_admin? ? "Yes" : "No", class: a.super_admin? ? "orange" : "grey" }
      row(:active)     { |a| status_tag a.active? ? "Active" : "Deactivated", class: a.active? ? "green" : "red" }
      row :notes
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_ip
      row :failed_attempts
      row :locked_at
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Credentials" do
      f.input :email
      f.input :password,              hint: "Leave blank to keep current password"
      f.input :password_confirmation, hint: "Only required when changing password"
    end
    f.inputs "Access" do
      f.input :role,        as: :select, collection: AdminUser::ROLES.map { |r| [ r.humanize, r ] }
      f.input :super_admin, as: :boolean, label: "Super Admin (full access)"
      f.input :active,      as: :boolean
      f.input :notes,       as: :text, hint: "Internal notes about this admin account"
    end
    f.actions
  end

  # Deactivate action (safer than delete)
  member_action :deactivate, method: :post do
    resource.update!(active: false)
    redirect_to admin_admin_user_path(resource), notice: "Admin user deactivated."
  end

  action_item :deactivate, only: :show, if: -> { resource.active? && resource != current_admin_user } do
    link_to "Deactivate", deactivate_admin_admin_user_path(resource), method: :post,
            data: { confirm: "Deactivate this admin user?" }
  end
end
