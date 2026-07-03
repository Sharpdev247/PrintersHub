ActiveAdmin.register City do
  menu priority: 10, label: "Cities"

  permit_params :state_id, :name, :latitude, :longitude

  scope :all, default: true
  scope :geocoded

  filter :name
  filter :state,   as: :select, collection: -> { State.includes(:country).order("countries.name, states.name").map { |s| [ "#{s.country.flag_emoji} #{s.country.name} — #{s.name}", s.id ] } }
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column :state
    column("Country") { |c| "#{c.state.country.flag_emoji} #{c.state.country.name}" }
    column :latitude
    column :longitude
    column("Geocoded") do |c|
      status_tag c.coordinates? ? "Yes" : "No", class: c.coordinates? ? "yes" : "no"
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :state do |c|
        link_to c.state.name, admin_state_path(c.state)
      end
      row("Country") { |c| link_to "#{c.country.flag_emoji} #{c.country.name}", admin_country_path(c.country) }
      row :latitude
      row :longitude
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "City Details" do
      f.input :state, as: :select,
              collection: State.includes(:country).order("countries.name, states.name").map { |s|
                [ "#{s.country.flag_emoji} #{s.country.name} — #{s.name}", s.id ]
              },
              include_blank: false
      f.input :name
    end
    f.inputs "Coordinates (optional)" do
      f.input :latitude,  hint: "Decimal degrees (e.g. 31.5204 for Lahore)"
      f.input :longitude, hint: "Decimal degrees (e.g. 74.3587 for Lahore)"
    end
    f.actions
  end

  config.sort_order = "name_asc"
end
