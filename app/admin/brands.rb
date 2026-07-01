ActiveAdmin.register Brand do
  menu priority: 6, label: "Brands"

  permit_params :name, :description, :website, :active

  scope :all, default: true
  scope :active
  scope :inactive

  filter :name
  filter :slug
  filter :active
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column :slug
    column :website do |b|
      link_to b.website, b.website, target: "_blank", rel: "noopener" if b.website.present?
    end
    column("Models") { |b| b.printer_models.count }
    column :active do |b|
      status_tag b.active? ? "Active" : "Inactive", class: b.active? ? "yes" : "no"
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :slug
      row :description
      row :website do |b|
        link_to b.website, b.website, target: "_blank", rel: "noopener" if b.website.present?
      end
      row :active
      row :created_at
      row :updated_at
    end

    panel "Printer Models" do
      table_for brand.printer_models.ordered do
        column :name
        column :model_number
        column :release_year
        column :discontinued
        column("") { |m| link_to "View", admin_printer_model_path(m) }
      end
    end
  end

  form do |f|
    f.inputs "Brand Details" do
      f.input :name
      f.input :description, as: :text
      f.input :website,     placeholder: "https://www.example.com"
      f.input :active
    end
    f.actions
  end

  config.sort_order = "name_asc"
end
