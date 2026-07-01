ActiveAdmin.register Membership do
  menu priority: 4, label: "Memberships"

  permit_params :account_id, :user_id, :role, :title

  filter :account
  filter :role, as: :select, collection: Membership.roles.keys
  filter :discarded_at_present, as: :boolean, label: "Soft Deleted"
  filter :discarded_at_blank, as: :boolean, label: "Active (not deleted)"

  scope :all, default: true
  scope("Active")       { |s| s.kept }
  scope("Soft Deleted") { |s| s.where.not(discarded_at: nil) }

  index do
    selectable_column
    id_column
    column(:account) { |m| m.account ? link_to(m.account.name, admin_account_path(m.account)) : "-" }
    column("User Email") { |m| m.user ? link_to(m.user.email, admin_user_path(m.user)) : "-" }
    column :role
    column :title
    column :accepted_at
    column :discarded_at
    actions
  end

  show do
    attributes_table do
      row :id
      row(:account) { |m| m.account ? link_to(m.account.name, admin_account_path(m.account)) : "-" }
      row("User Email") { |m| m.user ? link_to(m.user.email, admin_user_path(m.user)) : "-" }
      row :role
      row :title
      row :accepted_at
      row :discarded_at
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Membership Details" do
      f.input :account
      f.input :user
      f.input :role, as: :select, collection: Membership.roles.keys
      f.input :title
    end
    f.actions
  end

  config.sort_order = "created_at_desc"
end
