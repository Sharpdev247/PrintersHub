ActiveAdmin.register Country do
  menu parent: "Geography", priority: 1, label: "Countries"

  # iso2/iso3 are settable only on create — changing them after addresses reference
  # the country would break ISO lookups in external systems.
  permit_params do
    base = %i[name phone_code currency_code currency_symbol continent
              locale_code flag_emoji timezone display_order active]
    base += %i[iso2 iso3] if params[:action] == "create"
    base
  end

  scope :all, default: true
  scope :active
  scope :inactive

  filter :name
  filter :iso2
  filter :iso3
  filter :continent,   as: :select, collection: Country::CONTINENTS
  filter :active
  filter :currency_code
  filter :created_at

  index do
    selectable_column
    id_column
    column("") { |c| c.flag_emoji }
    column :name
    column :iso2
    column :iso3
    column :continent
    column :currency_code
    column("States") { |c| c.states.count }
    column :active do |c|
      status_tag c.active? ? "Active" : "Inactive", class: c.active? ? "yes" : "no"
    end
    column :display_order
    actions
  end

  show do
    attributes_table do
      row("Flag")         { |c| c.flag_emoji }
      row :name
      row :iso2
      row :iso3
      row :phone_code
      row :currency_code
      row :currency_symbol
      row :continent
      row :locale_code
      row :timezone
      row :display_order
      row :active
      row :created_at
      row :updated_at
    end

    panel "States (#{country.states.count})" do
      table_for country.states.ordered do
        column :name
        column :code
        column("Cities") { |s| s.cities.count }
        column("") { |s| link_to "View", admin_state_path(s) }
      end
    end
  end

  form do |f|
    f.inputs "Country Identity" do
      f.input :name
      if f.object.new_record?
        f.input :iso2, hint: "2-letter ISO 3166-1 code (e.g. PK). Cannot be changed after creation."
        f.input :iso3, hint: "3-letter ISO 3166-1 code (e.g. PAK). Cannot be changed after creation."
      end
      f.input :flag_emoji,   hint: "Paste the country flag emoji (e.g. 🇵🇰)"
      f.input :phone_code,   hint: "With + prefix (e.g. +92)"
      f.input :display_order, hint: "Lower number = appears earlier in dropdowns"
    end
    f.inputs "Currency & Localisation" do
      f.input :currency_code,   hint: "ISO 4217 (e.g. PKR, USD, GBP)"
      f.input :currency_symbol, hint: "Symbol for display (e.g. ₨, $, £)"
      f.input :locale_code,     hint: "BCP 47 locale (e.g. en-PK, ar-SA)"
      f.input :timezone,        hint: "TZ database name (e.g. Asia/Karachi)"
      f.input :continent,       as: :select, collection: Country::CONTINENTS, include_blank: "— Select continent —"
    end
    f.inputs "Status" do
      f.input :active
    end
    f.actions
  end

  config.sort_order = "display_order_asc"
end
