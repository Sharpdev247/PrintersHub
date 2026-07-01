# Core marketplace listing table.
#
# FK delete strategies:
#   user       → RESTRICT  : can't delete a seller who has listings
#   category   → RESTRICT  : categories with listings are protected
#   brand      → RESTRICT  : brands with listings are protected
#   printer_model → NULLIFY: deleting a model doesn't kill the listing
#   location_city → NULLIFY: deleting a city clears the location, listing survives
#
# Enum integers stored explicitly so future reordering can't corrupt existing data.
# pg_trgm GIN index on title enables fast ILIKE search; foundation for pg_search later.
class CreateListings < ActiveRecord::Migration[8.1]
  def change
    create_table :listings do |t|
      # Required FK references — RESTRICT protects data integrity
      t.references :user,     null: false, foreign_key: { on_delete: :restrict }
      t.references :category, null: false, foreign_key: { on_delete: :restrict }
      t.references :brand,    null: false, foreign_key: { on_delete: :restrict }

      # Optional FK references — nullable, NULLIFY on parent delete
      t.bigint :printer_model_id   # FK added below with on_delete: :nullify
      t.bigint :location_city_id   # FK added below with on_delete: :nullify

      # Core content
      t.string  :title,             null: false
      t.string  :slug,              null: false
      t.text    :description,       null: false

      # Marketplace taxonomy
      # listing_type: 0=sale 1=rental 2=service 3=wanted
      t.integer :listing_type,      null: false, default: 0
      # condition: 0=brand_new 1=like_new 2=good 3=fair 4=poor
      t.integer :condition,         null: false, default: 0

      # Pricing
      t.decimal :price,             null: false, precision: 12, scale: 2
      t.string  :currency,          null: false, default: "USD", limit: 3
      t.boolean :price_negotiable,  null: false, default: false

      # Inventory
      t.integer :quantity,          null: false, default: 1
      t.integer :year                           # year of manufacture — nullable

      # Workflow — status: 0=draft 1=published 2=sold 3=archived
      t.integer :status,            null: false, default: 0

      # Promotion
      t.boolean :featured,          null: false, default: false

      # Analytics
      t.integer :views_count,       null: false, default: 0

      # Timestamps
      t.datetime :published_at      # set when first published

      t.timestamps
    end

    # ── Indexes ────────────────────────────────────────────────────────────────

    # Slug — globally unique URL identifier
    add_index :listings, :slug, unique: true

    # Status — most queries filter by status
    add_index :listings, :status
    add_index :listings, :featured

    # published_at — sort newest published listings
    add_index :listings, :published_at, where: "published_at IS NOT NULL"

    # Composite — primary query patterns for marketplace pages
    add_index :listings, [ :user_id, :status ],     name: "index_listings_on_user_and_status"
    add_index :listings, [ :category_id, :status ], name: "index_listings_on_category_and_status"
    add_index :listings, [ :brand_id, :status ],    name: "index_listings_on_brand_and_status"
    add_index :listings, [ :listing_type, :status ], name: "index_listings_on_type_and_status"

    # Nullable FK indexes — partial so NULL rows are excluded (saves index space)
    add_index :listings, :printer_model_id,  where: "printer_model_id IS NOT NULL"
    add_index :listings, :location_city_id,  where: "location_city_id IS NOT NULL"
    add_index :listings, [ :location_city_id, :status ],
              where: "location_city_id IS NOT NULL",
              name: "index_listings_on_city_and_status"

    # Price — sorting and range filters
    add_index :listings, :price

    # GIN trigram index — enables fast ILIKE '%query%' on title (pg_trgm required)
    add_index :listings, :title, using: :gin, opclass: :gin_trgm_ops,
              name: "index_listings_on_title_trigram"

    # ── Foreign Keys ───────────────────────────────────────────────────────────
    add_foreign_key :listings, :printer_models, column: :printer_model_id, on_delete: :nullify
    add_foreign_key :listings, :cities,         column: :location_city_id, on_delete: :nullify

    # ── Database-level CHECK constraints ───────────────────────────────────────

    # Price must be positive (model validates this too; DB is the hard stop)
    add_check_constraint :listings,
      "price > 0",
      name: "chk_listings_price_positive"

    # Quantity cannot be negative
    add_check_constraint :listings,
      "quantity >= 0",
      name: "chk_listings_quantity_non_negative"

    # Currency must be a 3-letter ISO 4217 code
    add_check_constraint :listings,
      "currency ~ '^[A-Z]{3}$'",
      name: "chk_listings_currency_format"

    # published_at must be set when status is published (1) or sold (2)
    add_check_constraint :listings,
      "status NOT IN (1, 2) OR published_at IS NOT NULL",
      name: "chk_listings_published_at_when_live"
  end
end
