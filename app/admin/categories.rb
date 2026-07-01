ActiveAdmin.register Category do
  menu priority: 5, label: "Categories"

  # ancestry is written via parent_id exposed by the ancestry gem
  permit_params :name, :description, :parent_id, :position, :active, :icon

  scope :all, default: true
  scope :active
  scope :inactive
  scope :top_level

  filter :name
  filter :slug
  filter :active
  filter :ancestry, label: "Ancestry Path"

  index do
    selectable_column
    id_column
    # depth_label prepends dashes so hierarchy is visible in a flat list
    column :name do |cat|
      cat.depth_label
    end
    column :slug
    column("Parent") { |cat| cat.parent&.name || "—" }
    column("Children") { |cat| cat.children.count }
    column :position
    column :active do |cat|
      status_tag cat.active? ? "Active" : "Inactive", class: cat.active? ? "yes" : "no"
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :slug
      row :description
      row("Breadcrumb") { |cat| cat.breadcrumb.join(" › ") }
      row("Parent")     { |cat| cat.parent&.name || "Root" }
      row("Depth")      { |cat| cat.depth }
      row :position
      row :active
      row :icon
      row :created_at
      row :updated_at
    end

    panel "Child Categories" do
      table_for category.children.ordered do
        column :name
        column :active
        column("") { |c| link_to "View", admin_category_path(c) }
      end
    end
  end

  form do |f|
    f.inputs "Category Details" do
      f.input :name
      f.input :description, as: :text
      f.input :parent,
              as: :select,
              collection: Category.all.sort_by(&:depth).map { |c| [c.depth_label, c.id] },
              include_blank: "— No Parent (Root) —"
      f.input :position, hint: "Lower numbers appear first within the same parent"
      f.input :active
      f.input :icon, hint: "CSS class or icon identifier for frontend use"
    end
    f.actions
  end

  # Default sort: ancestry path + position so the tree order is preserved
  config.sort_order = "ancestry_asc"
end
