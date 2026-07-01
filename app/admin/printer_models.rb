ActiveAdmin.register PrinterModel do
  menu priority: 7, label: "Printer Models"

  permit_params :brand_id, :category_id, :name, :model_number,
                :description, :release_year, :discontinued

  scope :all, default: true
  scope :current
  scope :discontinued

  filter :name
  filter :slug
  filter :brand,        as: :select, collection: Brand.active.ordered
  filter :category,     as: :select, collection: Category.active.ordered
  filter :model_number
  filter :release_year
  filter :discontinued

  index do
    selectable_column
    id_column
    column :name
    column :brand
    column :category
    column :model_number
    column :release_year
    column :discontinued do |m|
      status_tag m.discontinued? ? "Discontinued" : "Current",
                 class: m.discontinued? ? "no" : "yes"
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :slug
      row :brand
      row :category
      row :model_number
      row :description
      row :release_year
      row :discontinued
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Model Details" do
      f.input :brand,        as: :select, collection: Brand.active.ordered.map { |b| [b.name, b.id] }
      f.input :category,     as: :select,
                             collection: Category.active.sort_by(&:depth).map { |c| [c.depth_label, c.id] },
                             include_blank: "— Uncategorised —"
      f.input :name
      f.input :model_number, hint: "Manufacturer's official part/model number"
      f.input :description,  as: :text
      f.input :release_year, hint: "Year the model was released"
      f.input :discontinued
    end
    f.actions
  end

  config.sort_order = "name_asc"
end
