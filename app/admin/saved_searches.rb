ActiveAdmin.register SavedSearch do
  menu parent: "Catalog", priority: 5, label: "Saved Searches"

  permit_params :user_id, :name, :alert_enabled, filters: {}

  actions :index, :show, :destroy

  filter :user,          as: :select, collection: -> { User.order(:email).map { |u| [ u.email, u.id ] } }
  filter :name
  filter :alert_enabled, as: :boolean
  filter :created_at

  scope :all,          default: true
  scope("With Alerts") { |s| s.with_alerts }

  index do
    selectable_column
    id_column
    column :user
    column :name
    column :alert_enabled do |ss|
      status_tag ss.alert_enabled? ? "Yes" : "No", class: ss.alert_enabled? ? "yes" : "no"
    end
    column("Filters") { |ss| ss.filters.keys.join(", ").presence || "—" }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :user
      row :name
      row :alert_enabled
      row :created_at
      row :updated_at
    end

    panel "Filters Payload" do
      pre do
        JSON.pretty_generate(saved_search.filters)
      end
    end
  end

  config.sort_order = "created_at_desc"
end
