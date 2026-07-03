ActiveAdmin.register Company do
  menu priority: 4, label: "Companies"

  permit_params :user_id, :name, :email, :phone, :website,
                :description, :tax_number, :company_type, :verified, :verified_at

  # Scopes for the most common admin workflows
  scope :all, default: true
  scope :verified
  scope :unverified

  filter :name
  filter :slug
  filter :email
  filter :company_type, as: :select, collection: Company.company_types.keys.map { |k| [ k.humanize, k ] }
  filter :verified
  filter :user_id, label: "User ID"
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column :slug
    column :company_type
    column :email
    column :verified do |c|
      status_tag c.verified? ? "Yes" : "No", class: c.verified? ? "yes" : "no"
    end
    column :user
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :slug
      row :email
      row :phone
      row :website
      row :description
      row :tax_number
      row :company_type
      row :verified do |c|
        status_tag c.verified? ? "Verified" : "Unverified", class: c.verified? ? "yes" : "no"
      end
      row :verified_at
      row :user
      row :created_at
      row :updated_at
    end

    panel "Addresses" do
      table_for company.addresses do
        column :label
        column :address_type
        column :line1
        column :city
        column :country_code
        column :is_primary
      end
    end
  end

  form do |f|
    f.inputs "Company Details" do
      f.input :user,         as: :select, collection: User.order(:email).map { |u| [ u.email, u.id ] }
      f.input :name
      f.input :email
      f.input :phone
      f.input :website,      placeholder: "https://"
      f.input :description,  as: :text
      f.input :tax_number
      f.input :company_type, as: :select, collection: Company.company_types.keys.map { |k| [ k.humanize, k ] }
    end
    f.inputs "Verification" do
      f.input :verified
      f.input :verified_at, as: :datetime_picker, hint: "Set when marking as verified"
    end
    f.actions
  end

  config.sort_order = "name_asc"
end
