ActiveAdmin.register Favorite do
  menu priority: 6, label: "Favorites"

  permit_params :user_id, :listing_id

  actions :index, :show, :destroy

  filter :user,    as: :select, collection: -> { User.order(:email).map { |u| [ u.email, u.id ] } }
  filter :listing, as: :select, collection: -> { Listing.order(:title).map { |l| [ truncate(l.title, length: 60), l.id ] } }
  filter :created_at

  scope :all, default: true

  index do
    selectable_column
    id_column
    column :user
    column("Listing") do |f|
      link_to truncate(f.listing.title, length: 60), admin_listing_path(f.listing)
    end
    column("Listing Status") { |f| status_tag f.listing.status }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :user
      row :listing do |f|
        link_to f.listing.title, admin_listing_path(f.listing)
      end
      row :created_at
      row :updated_at
    end
  end

  config.sort_order = "created_at_desc"
end
