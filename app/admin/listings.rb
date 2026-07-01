ActiveAdmin.register Listing do
  menu priority: 5, label: "Listings"

  permit_params :user_id, :category_id, :brand_id, :printer_model_id, :location_city_id,
                :title, :description, :listing_type, :condition, :price, :currency,
                :price_negotiable, :quantity, :year, :status, :featured, :published_at,
                images: [], documents: []

  # ── Scopes ──────────────────────────────────────────────────────────────────
  scope :all, default: true
  scope("Draft")     { |s| s.draft }
  scope("Published") { |s| s.published }
  scope("Sold")      { |s| s.sold }
  scope("Archived")  { |s| s.archived }
  scope("Featured")  { |s| s.featured }

  # ── Filters ─────────────────────────────────────────────────────────────────
  filter :title
  filter :status, as: :select, collection: Listing.statuses.keys.map { |s| [s.humanize, s] }
  filter :listing_type, as: :select, collection: Listing.listing_types.keys.map { |t| [t.humanize, t] }
  filter :condition, as: :select, collection: Listing.conditions.keys.map { |c| [c.humanize, c] }
  filter :user,     as: :select, collection: -> { User.joins(:listings).distinct.map { |u| [u.email, u.id] } }
  filter :category, as: :select, collection: -> { Category.ordered.map { |c| [c.depth_label, c.id] } }
  filter :brand,    as: :select, collection: -> { Brand.ordered }
  filter :featured, as: :boolean
  filter :price
  filter :published_at
  filter :created_at

  # ── Index ───────────────────────────────────────────────────────────────────
  index do
    selectable_column
    id_column
    column :title do |l|
      link_to truncate(l.title, length: 60), admin_listing_path(l)
    end
    column :brand
    column :category
    column :listing_type do |l|
      l.listing_type.humanize
    end
    column :condition do |l|
      l.condition.humanize
    end
    column :price do |l|
      number_to_currency(l.price, unit: l.currency, precision: 0)
    end
    column :status do |l|
      classes = { "published" => "yes", "draft" => "no", "sold" => "orange", "archived" => "no" }
      status_tag l.status.humanize, class: classes[l.status] || "no"
    end
    column :featured do |l|
      status_tag l.featured? ? "Yes" : "No", class: l.featured? ? "yes" : "no"
    end
    column :published_at
    column :created_at
    actions
  end

  # ── Show ────────────────────────────────────────────────────────────────────
  show do
    attributes_table do
      row :id
      row :title
      row :slug
      row :user
      row :brand
      row :category
      row :printer_model
      row :location_city
      row :listing_type do |l| l.listing_type.humanize end
      row :condition     do |l| l.condition.humanize end
      row :price do |l|
        number_to_currency(l.price, unit: l.currency, precision: 2)
      end
      row :price_negotiable
      row :quantity
      row :year
      row :status do |l|
        classes = { "published" => "yes", "draft" => "no", "sold" => "orange", "archived" => "no" }
        status_tag l.status.humanize, class: classes[l.status] || "no"
      end
      row :featured
      row :views_count
      row :published_at
      row :created_at
      row :updated_at
    end

    panel "Description" do
      div do
        simple_format listing.description
      end
    end

    if listing.images.attached?
      panel "Images (#{listing.images.count})" do
        div class: "admin-images" do
          listing.images.each do |img|
            div style: "display:inline-block; margin: 4px;" do
              image_tag rails_blob_url(img), style: "max-height:160px; max-width:220px; border:1px solid #ddd; border-radius:4px;"
            end
          end
        end
      end
    end

    if listing.documents.attached?
      panel "Documents (#{listing.documents.count})" do
        table_for listing.documents do
          column("Filename") { |d| link_to d.filename.to_s, rails_blob_url(d), target: "_blank" }
          column("Size")     { |d| number_to_human_size(d.byte_size) }
          column("Type")     { |d| d.content_type }
        end
      end
    end
  end

  # ── Form ────────────────────────────────────────────────────────────────────
  form do |f|
    f.inputs "Listing Details" do
      f.input :user, as: :select, collection: User.order(:email).map { |u| [u.email, u.id] }, include_blank: false
      f.input :title
      f.input :description
    end

    f.inputs "Classification" do
      f.input :listing_type, as: :select, collection: Listing.listing_types.keys.map { |t| [t.humanize, t] }, include_blank: false
      f.input :condition,    as: :select, collection: Listing.conditions.keys.map { |c| [c.humanize, c] }, include_blank: false
      f.input :category, as: :select, collection: Category.ordered.map { |c| [c.depth_label, c.id] }, include_blank: false
      f.input :brand, as: :select, collection: Brand.ordered, include_blank: false
      f.input :printer_model, as: :select, collection: PrinterModel.ordered.map { |pm| [pm.full_model_name, pm.id] }, include_blank: true
    end

    f.inputs "Pricing & Inventory" do
      f.input :price, hint: "Enter numeric value only"
      f.input :currency, hint: "3-letter ISO code, e.g. USD, PKR, GBP"
      f.input :price_negotiable
      f.input :quantity
      f.input :year, hint: "Year of manufacture (optional)"
    end

    f.inputs "Location" do
      f.input :location_city, as: :select,
              collection: City.joins(:state).includes(:state).order("states.name, cities.name").map { |c|
                ["#{c.state.name} — #{c.name}", c.id]
              },
              include_blank: true
    end

    f.inputs "Status & Promotion" do
      f.input :status, as: :select, collection: Listing.statuses.keys.map { |s| [s.humanize, s] }, include_blank: false
      f.input :featured
      f.input :published_at, as: :datetime_picker, hint: "Leave blank for drafts; auto-set when published via action"
    end

    f.inputs "Images (max #{Listing::MAX_IMAGES})" do
      f.input :images, as: :file, input_html: { multiple: true },
              hint: "JPEG, PNG, WebP, GIF — max #{Listing::MAX_IMAGE_SIZE / 1.megabyte} MB each"
    end

    f.inputs "Documents (max #{Listing::MAX_DOCUMENTS})" do
      f.input :documents, as: :file, input_html: { multiple: true },
              hint: "PDF only — max #{Listing::MAX_DOCUMENT_SIZE / 1.megabyte} MB each"
    end

    f.actions
  end

  # ── Member Actions ──────────────────────────────────────────────────────────
  member_action :publish, method: :put do
    resource.publish!
    redirect_to admin_listing_path(resource), notice: "Listing published."
  rescue => e
    redirect_to admin_listing_path(resource), alert: "Could not publish: #{e.message}"
  end

  member_action :archive, method: :put do
    resource.archive!
    redirect_to admin_listing_path(resource), notice: "Listing archived."
  end

  member_action :mark_sold, method: :put do
    resource.mark_sold!
    redirect_to admin_listing_path(resource), notice: "Listing marked as sold."
  end

  member_action :feature, method: :put do
    resource.update!(featured: true)
    redirect_to admin_listing_path(resource), notice: "Listing featured."
  end

  member_action :unfeature, method: :put do
    resource.update!(featured: false)
    redirect_to admin_listing_path(resource), notice: "Listing unfeatured."
  end

  # ── Action Items (show page buttons) ────────────────────────────────────────
  action_item :publish, only: :show, if: -> { resource.status_draft? || resource.status_archived? } do
    link_to "Publish", publish_admin_listing_path(resource), method: :put,
            data: { confirm: "Publish this listing?" }
  end

  action_item :archive, only: :show, if: -> { resource.status_published? } do
    link_to "Archive", archive_admin_listing_path(resource), method: :put,
            data: { confirm: "Archive this listing?" }
  end

  action_item :mark_sold, only: :show, if: -> { resource.status_published? } do
    link_to "Mark Sold", mark_sold_admin_listing_path(resource), method: :put,
            data: { confirm: "Mark this listing as sold?" }
  end

  action_item :feature, only: :show, if: -> { !resource.featured? } do
    link_to "Feature", feature_admin_listing_path(resource), method: :put
  end

  action_item :unfeature, only: :show, if: -> { resource.featured? } do
    link_to "Unfeature", unfeature_admin_listing_path(resource), method: :put
  end

  config.sort_order = "created_at_desc"
end
