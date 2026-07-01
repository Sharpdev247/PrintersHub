ActiveAdmin.register TaxRate do
  permit_params :name, :country_code, :state_code, :tax_type, :rate, :active, :description

  scope :all
  scope("Active")   { |s| s.active }
  scope("VAT")      { |s| s.tax_type_vat }
  scope("GST")      { |s| s.tax_type_gst }
  scope("Sales Tax"){ |s| s.tax_type_sales_tax }

  filter :name
  filter :country_code
  filter :state_code
  filter :tax_type, as: :select, collection: TaxRate.tax_types.keys.map { |t| [t.humanize, t] }
  filter :active
  filter :rate

  index do
    selectable_column
    id_column
    column :name
    column :country_code
    column :state_code
    column :tax_type do |tr|
      tr.tax_type&.humanize
    end
    column :rate do |tr|
      "#{tr.rate_percentage}%"
    end
    column :active do |tr|
      status_tag tr.active? ? "Active" : "Inactive"
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :country_code
      row :state_code
      row :tax_type
      row :rate { |tr| "#{tr.rate_percentage}%" }
      row :description
      row :active { |tr| status_tag tr.active? ? "Active" : "Inactive" }
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Tax Rate Details" do
      f.input :name
      f.input :country_code
      f.input :state_code
      f.input :tax_type, as: :select, collection: TaxRate.tax_types.keys.map { |t| [t.humanize, t] }
      f.input :rate, hint: "Enter as decimal (e.g. 0.17 for 17%)"
      f.input :active
      f.input :description
    end
    f.actions
  end
end
