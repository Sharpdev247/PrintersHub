ActiveAdmin.register State do
  menu parent: "Geography", priority: 2, label: "States"

  permit_params :country_id, :name, :code

  filter :name
  filter :code
  filter :country, as: :select, collection: -> { Country.active.ordered.map { |c| [ "#{c.flag_emoji} #{c.name}", c.id ] } }
  filter :created_at

  index do
    selectable_column
    id_column
    column :country do |s|
      "#{s.country.flag_emoji} #{s.country.name}"
    end
    column :name
    column :code
    column("Cities") { |s| s.cities.count }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :country do |s|
        link_to "#{s.country.flag_emoji} #{s.country.name}", admin_country_path(s.country)
      end
      row :name
      row :code
      row :created_at
      row :updated_at
    end

    panel "Cities (#{state.cities.count})" do
      table_for state.cities.ordered do
        column :name
        column :latitude
        column :longitude
        column("") { |c| link_to "View", admin_city_path(c) }
      end
    end
  end

  form do |f|
    f.inputs "State Details" do
      f.input :country, as: :select,
              collection: Country.active.ordered.map { |c| [ "#{c.flag_emoji} #{c.name}", c.id ] },
              include_blank: false
      f.input :name
      f.input :code, hint: "Short code if applicable (e.g. PB for Punjab). Optional."
    end
    f.actions
  end

  config.sort_order = "name_asc"
end
