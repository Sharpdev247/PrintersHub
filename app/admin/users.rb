ActiveAdmin.register User do
  menu priority: 2, label: "Users"

  permit_params :email, :password, :password_confirmation, :confirmed_at

  filter :email
  filter :confirmed_at
  filter :sign_in_count
  filter :created_at
  filter :locked_at

  scope :all, default: true
  scope("Confirmed")   { |s| s.where.not(confirmed_at: nil) }
  scope("Unconfirmed") { |s| s.where(confirmed_at: nil) }
  scope("Locked")      { |s| s.where.not(locked_at: nil) }

  index do
    selectable_column
    id_column
    column :email
    column("Confirmed") { |u| status_tag u.confirmed? ? "Yes" : "No", class: u.confirmed? ? "yes" : "no" }
    column("Locked")    { |u| status_tag u.access_locked? ? "Yes" : "No", class: u.access_locked? ? "no" : "yes" }
    column :sign_in_count
    column :last_sign_in_at
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :confirmed_at
      row :sign_in_count
      row :last_sign_in_at
      row :current_sign_in_ip
      row :failed_attempts
      row :locked_at
      row :created_at
      row :updated_at
    end

    panel "Listings (#{user.listings.count})" do
      table_for user.listings.order(created_at: :desc).limit(10) do
        column :title do |l| link_to truncate(l.title, length: 60), admin_listing_path(l) end
        column :status
        column :price
        column :created_at
      end
    end

    panel "Roles (#{user.roles.count})" do
      table_for user.roles do
        column :name
        column :description
      end
    end
  end

  form do |f|
    f.inputs "Account Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :confirmed_at, as: :datetime_picker, hint: "Set to confirm the email manually"
    end
    f.actions
  end

  config.sort_order = "created_at_desc"
end
