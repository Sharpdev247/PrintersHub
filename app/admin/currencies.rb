ActiveAdmin.register Currency do
  permit_params :code, :name, :symbol, :exchange_rate, :active, :is_default,
                :exchange_rate_updated_at

  scope :all
  scope("Active") { |s| s.active }

  filter :code
  filter :name
  filter :active
  filter :is_default

  index do
    selectable_column
    id_column
    column :code
    column :name
    column :symbol
    column :exchange_rate
    column :exchange_rate_updated_at
    column(:active)     { |c| status_tag c.active? ? "Active" : "Inactive" }
    column(:is_default) { |c| status_tag c.is_default? ? "Default" : "" if c.is_default? }
    actions
  end

  show do
    attributes_table do
      row :id
      row :code
      row :name
      row :symbol
      row :exchange_rate
      row :exchange_rate_updated_at
      row(:active)     { |c| status_tag c.active? ? "Active" : "Inactive" }
      row(:is_default) { |c| c.is_default? ? "Yes (Default)" : "No" }
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Currency Details" do
      f.input :code
      f.input :name
      f.input :symbol
      f.input :exchange_rate
      f.input :active
      f.input :is_default
      f.input :exchange_rate_updated_at, as: :datetime_picker
    end
    f.actions
  end
end
