ActiveAdmin.register SystemSetting do
  menu label: "System Settings", parent: "Platform", priority: 3

  permit_params :key, :value, :value_type, :category, :description, :editable

  actions :index, :show, :edit, :update, :new, :create

  filter :key
  filter :category, as: :select, collection: SystemSetting::CATEGORIES
  filter :value_type, as: :select, collection: SystemSetting::VALUE_TYPES
  filter :editable

  scope :all
  SystemSetting::CATEGORIES.each do |cat|
    scope(cat.humanize) { |s| s.where(category: cat) }
  end

  index do
    selectable_column
    id_column
    column :category do |s|
      status_tag s.category.humanize
    end
    column :key
    column(:value) { |s| truncate(s.value.to_s, length: 60) }
    column :value_type
    column(:editable) { |s| status_tag s.editable? ? "Yes" : "No", class: s.editable? ? "green" : "grey" }
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :key
      row :category
      row :value_type
      row :value
      row(:typed_value) { |s| s.typed_value.inspect }
      row :description
      row(:editable) { |s| status_tag s.editable? ? "Yes" : "No", class: s.editable? ? "green" : "grey" }
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Setting" do
      f.input :key,        hint: "Dot-notation key e.g. platform.name — cannot change after creation"
      f.input :value
      f.input :value_type, as: :select, collection: SystemSetting::VALUE_TYPES
      f.input :category,   as: :select, collection: SystemSetting::CATEGORIES
      f.input :description
      f.input :editable
    end
    f.actions
  end
end
