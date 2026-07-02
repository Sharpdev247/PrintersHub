ActiveAdmin.register Listing do
  menu priority: 5, label: "Listings"

  # Show all records including soft-deleted so admins have full visibility.
  controller do
    def scoped_collection
      Listing.with_discarded.includes(:account, :user, :category, :brand)
    end
  end

  permit_params :user_id, :account_id, :category_id, :brand_id, :printer_model_id,
                :location_city_id,
                :title, :description, :listing_type, :condition, :price, :currency,
                :price_negotiable, :quantity, :year, :status, :featured, :published_at,
                images: [], documents: []

  # ── Scopes ──────────────────────────────────────────────────────────────────
  scope("All",       default: true) { |s| s.with_discarded }
  scope("Active")    { |s| s.kept }
  scope("Draft")     { |s| s.kept.draft }
  scope("Published") { |s| s.kept.published }
  scope("Paused")    { |s| s.kept.paused }
  scope("Sold")      { |s| s.kept.sold }
  scope("Archived")  { |s| s.kept.archived }
  scope("Featured")  { |s| s.kept.featured }
  scope("Deleted")   { |s| s.discarded }

  # ── Filters ─────────────────────────────────────────────────────────────────
  filter :title
  filter :account,      as: :select, collection: -> { Account.kept.order(:name).pluck(:name, :id) }
  filter :status,       as: :select, collection: Listing.statuses.keys.map { |s| [s.humanize, s] }
  filter :listing_type, as: :select, collection: Listing.listing_types.keys.map { |t| [t.humanize, t] }
  filter :condition,    as: :select, collection: Listing.conditions.keys.map { |c| [c.humanize.gsub("_", " "), c] }
  filter :category,     as: :select, collection: -> { Category.order(:name).pluck(:name, :id) }
  filter :brand,        as: :select, collection: -> { Brand.order(:name).pluck(:name, :id) }
  filter :featured,     as: :boolean
  filter :price
  filter :published_at
  filter :discarded_at
  filter :created_at

  # ── Index ───────────────────────────────────────────────────────────────────
  index do
    selectable_column
    id_column

    column :title do |l|
      link_to truncate(l.title, length: 55), admin_listing_path(l)
    end
    column :account do |l|
      link_to l.account.name, admin_account_path(l.account)
    end
    column :brand
    column :category
    column(:listing_type) { |l| l.listing_type.humanize }
    column(:condition)    { |l| l.condition.humanize.gsub("_", " ") }
    column :price do |l|
      number_to_currency(l.price, unit: "#{l.currency} ", precision: 0)
    end
    column :status do |l|
      color = { "published" => "yes", "draft" => "no", "paused" => "orange",
                "sold" => "orange", "archived" => "no" }
      status_tag l.status.humanize, class: color[l.status] || "no"
    end
    column :featured do |l|
      status_tag(l.featured? ? "Yes" : "No", class: l.featured? ? "yes" : "no")
    end
    column :discarded_at do |l|
      l.discarded? ? status_tag("Deleted", class: "no") : "—"
    end
    column :published_at
    column :created_at
    actions
  end

  # ── Batch actions ────────────────────────────────────────────────────────────
  batch_action :publish do |ids|
    Listing.with_discarded.where(id: ids).each(&:publish!)
    redirect_to collection_path, notice: "Selected listings published."
  end

  batch_action :archive do |ids|
    Listing.with_discarded.where(id: ids).each(&:archive!)
    redirect_to collection_path, notice: "Selected listings archived."
  end

  # ── Show ────────────────────────────────────────────────────────────────────
  show do
    columns do
      column do
        attributes_table do
          row :id
          row :title
          row :slug
          row :account
          row :user
          row :brand
          row :category
          row :printer_model
          row :location_city
          row(:listing_type) { |l| l.listing_type.humanize }
          row(:condition)    { |l| l.condition.humanize.gsub("_", " ") }
          row :price do |l|
            number_to_currency(l.price, unit: "#{l.currency} ", precision: 2)
          end
          row :price_negotiable
          row :quantity
          row :year
          row :status do |l|
            color = { "published" => "yes", "draft" => "no", "paused" => "orange",
                      "sold" => "orange", "archived" => "no" }
            status_tag l.status.humanize, class: color[l.status] || "no"
          end
          row :featured
          row :views_count
          row :published_at
          row :discarded_at
          row :created_at
          row :updated_at
        end
      end

      column do
        panel "Description" do
          simple_format listing.description
        end

        if listing.images.attached?
          panel "Images (#{listing.images.count})" do
            listing.images.each do |img|
              span style: "display:inline-block;margin:4px" do
                image_tag rails_blob_url(img),
                          style: "max-height:150px;max-width:200px;border:1px solid #ddd;border-radius:4px"
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
    end
  end

  # ── Form ────────────────────────────────────────────────────────────────────
  form do |f|
    f.inputs "Ownership" do
      f.input :account, as: :select,
              collection: Account.kept.order(:name).map { |a| [a.name, a.id] },
              include_blank: false
      f.input :user, as: :select,
              collection: User.order(:email).map { |u| [u.email, u.id] },
              include_blank: false
    end

    f.inputs "Listing Details" do
      f.input :title
      f.input :description, as: :text, input_html: { rows: 6 }
    end

    f.inputs "Classification" do
      f.input :listing_type, as: :select,
              collection: Listing.listing_types.keys.map { |t| [t.humanize, t] },
              include_blank: false
      f.input :condition, as: :select,
              collection: Listing.conditions.keys.map { |c| [c.humanize.gsub("_", " "), c] },
              include_blank: false
      f.input :category, as: :select,
              collection: Category.order(:name).map { |c| [c.name, c.id] },
              include_blank: false
      f.input :brand, as: :select,
              collection: Brand.order(:name).map { |b| [b.name, b.id] },
              include_blank: false
      f.input :printer_model, as: :select,
              collection: PrinterModel.order(:name).map { |pm| [pm.name, pm.id] },
              include_blank: true
    end

    f.inputs "Pricing & Inventory" do
      f.input :price, hint: "Numeric value only"
      f.input :currency, hint: "3-letter ISO code e.g. USD, GBP, AED"
      f.input :price_negotiable
      f.input :quantity
      f.input :year, hint: "Year of manufacture (optional)"
    end

    f.inputs "Location" do
      f.input :location_city, as: :select,
              collection: City.order(:name).map { |c| [c.name, c.id] },
              include_blank: true
    end

    f.inputs "Status & Promotion" do
      f.input :status, as: :select,
              collection: Listing.statuses.keys.map { |s| [s.humanize, s] },
              include_blank: false
      f.input :featured
      f.input :published_at, as: :datetime_picker,
              hint: "Leave blank for drafts"
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

  member_action :discard, method: :put do
    resource.discard!
    redirect_to admin_listing_path(resource), notice: "Listing soft-deleted."
  end

  member_action :undiscard, method: :put do
    resource.undiscard!
    redirect_to admin_listing_path(resource), notice: "Listing restored."
  end

  # ── Action Items (show page) ─────────────────────────────────────────────────
  action_item :publish, only: :show,
              if: -> { !resource.status_published? && !resource.discarded? } do
    link_to "Publish", publish_admin_listing_path(resource), method: :put,
            data: { confirm: "Publish this listing?" }
  end

  action_item :archive, only: :show,
              if: -> { resource.status_published? && !resource.discarded? } do
    link_to "Archive", archive_admin_listing_path(resource), method: :put,
            data: { confirm: "Archive this listing?" }
  end

  action_item :mark_sold, only: :show,
              if: -> { resource.status_published? && !resource.discarded? } do
    link_to "Mark Sold", mark_sold_admin_listing_path(resource), method: :put,
            data: { confirm: "Mark this listing as sold?" }
  end

  action_item :feature, only: :show,
              if: -> { !resource.featured? && !resource.discarded? } do
    link_to "Feature", feature_admin_listing_path(resource), method: :put
  end

  action_item :unfeature, only: :show,
              if: -> { resource.featured? } do
    link_to "Unfeature", unfeature_admin_listing_path(resource), method: :put
  end

  action_item :discard, only: :show,
              if: -> { !resource.discarded? } do
    link_to "Soft Delete", discard_admin_listing_path(resource), method: :put,
            data: { confirm: "Soft-delete this listing? It will be hidden from the marketplace." },
            style: "background:#dc2626!important"
  end

  action_item :undiscard, only: :show,
              if: -> { resource.discarded? } do
    link_to "Restore", undiscard_admin_listing_path(resource), method: :put,
            data: { confirm: "Restore this listing?" },
            style: "background:#16a34a!important"
  end

  config.sort_order = "created_at_desc"
end
