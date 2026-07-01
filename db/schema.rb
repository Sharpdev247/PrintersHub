# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_01_155010) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "account_subscriptions", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "billing_interval", default: "monthly", null: false
    t.datetime "cancelled_at"
    t.bigint "coupon_redemption_id"
    t.datetime "created_at", null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.datetime "current_period_end"
    t.datetime "current_period_start"
    t.decimal "current_price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "discarded_at"
    t.datetime "expires_at"
    t.jsonb "metadata", default: {}, null: false
    t.string "payment_provider"
    t.string "provider_subscription_id"
    t.integer "status", default: 0, null: false
    t.bigint "subscription_plan_id", null: false
    t.datetime "trial_ends_at"
    t.datetime "updated_at", null: false
    t.index ["account_id", "status"], name: "index_account_subscriptions_on_account_and_status"
    t.index ["account_id"], name: "index_account_subscriptions_on_account_active", unique: true, where: "((status = ANY (ARRAY[0, 1, 2])) AND (discarded_at IS NULL))"
    t.index ["account_id"], name: "index_account_subscriptions_on_account_id"
    t.index ["coupon_redemption_id"], name: "index_account_subscriptions_on_coupon_redemption", where: "(coupon_redemption_id IS NOT NULL)"
    t.index ["expires_at"], name: "index_account_subscriptions_on_expires_at_active", where: "((expires_at IS NOT NULL) AND (status = ANY (ARRAY[0, 1])))"
    t.index ["provider_subscription_id"], name: "index_account_subscriptions_on_provider_id", unique: true, where: "(provider_subscription_id IS NOT NULL)"
    t.index ["subscription_plan_id"], name: "index_account_subscriptions_on_subscription_plan_id"
    t.check_constraint "billing_interval::text = ANY (ARRAY['monthly'::character varying, 'yearly'::character varying]::text[])", name: "chk_account_subscriptions_billing_interval"
    t.check_constraint "currency::text ~ '^[A-Z]{3}$'::text", name: "chk_account_subscriptions_currency"
    t.check_constraint "current_price >= 0::numeric", name: "chk_account_subscriptions_price"
  end

  create_table "accounts", force: :cascade do |t|
    t.integer "account_type", default: 0, null: false
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "email", limit: 255
    t.string "name", null: false
    t.string "phone", limit: 30
    t.string "provider_customer_id"
    t.jsonb "settings", default: {}, null: false
    t.string "slug", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false, null: false
    t.datetime "verified_at"
    t.string "website", limit: 255
    t.index ["account_type"], name: "index_accounts_on_account_type"
    t.index ["discarded_at"], name: "index_accounts_on_discarded_at", where: "(discarded_at IS NOT NULL)"
    t.index ["provider_customer_id"], name: "index_accounts_on_provider_customer_id", unique: true, where: "(provider_customer_id IS NOT NULL)"
    t.index ["settings"], name: "index_accounts_on_settings_gin", using: :gin
    t.index ["slug"], name: "index_accounts_on_slug", unique: true
    t.index ["status"], name: "index_accounts_on_status"
    t.index ["verified"], name: "index_accounts_on_verified"
    t.check_constraint "length(name::text) >= 2", name: "chk_accounts_name_length"
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.bigint "author_id"
    t.string "author_type"
    t.text "body"
    t.datetime "created_at", null: false
    t.string "namespace"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "address_type", default: "default", null: false
    t.bigint "addressable_id", null: false
    t.string "addressable_type", null: false
    t.bigint "city_id"
    t.string "city_name"
    t.string "country_code", limit: 2, default: "US"
    t.bigint "country_id"
    t.datetime "created_at", null: false
    t.boolean "is_primary", default: false, null: false
    t.string "label"
    t.decimal "latitude", precision: 10, scale: 8
    t.string "line1", null: false
    t.string "line2"
    t.decimal "longitude", precision: 11, scale: 8
    t.string "postal_code", null: false
    t.bigint "state_id"
    t.string "state_name"
    t.datetime "updated_at", null: false
    t.index ["addressable_type", "addressable_id", "is_primary"], name: "index_addresses_on_addressable_and_primary"
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
    t.index ["city_id"], name: "index_addresses_on_city_id", where: "(city_id IS NOT NULL)"
    t.index ["country_id"], name: "index_addresses_on_country_id", where: "(country_id IS NOT NULL)"
    t.index ["state_id"], name: "index_addresses_on_state_id", where: "(state_id IS NOT NULL)"
    t.check_constraint "address_type::text = ANY (ARRAY['billing'::character varying, 'shipping'::character varying, 'default'::character varying, 'other'::character varying]::text[])", name: "chk_addresses_address_type"
    t.check_constraint "country_code IS NULL OR country_code::text ~ '^[A-Z]{2}$'::text", name: "chk_addresses_country_code"
    t.check_constraint "country_id IS NOT NULL OR country_code IS NOT NULL", name: "chk_addresses_has_country"
  end

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admin_users_on_unlock_token", unique: true
  end

  create_table "audits", force: :cascade do |t|
    t.string "action"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "auditable_id"
    t.string "auditable_type"
    t.text "audited_changes"
    t.string "comment"
    t.datetime "created_at"
    t.string "remote_address"
    t.string "request_uuid"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.integer "version", default: 0
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "brands", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["active"], name: "index_brands_on_active"
    t.index ["name"], name: "index_brands_on_name", unique: true
    t.index ["slug"], name: "index_brands_on_slug", unique: true
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "added_by_id"
    t.bigint "cart_id", null: false
    t.datetime "created_at", null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.bigint "listing_id", null: false
    t.text "notes"
    t.integer "quantity", default: 1, null: false
    t.decimal "unit_price", precision: 12, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["added_by_id"], name: "index_cart_items_on_added_by_id"
    t.index ["cart_id", "listing_id"], name: "index_cart_items_on_cart_and_listing", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["listing_id"], name: "index_cart_items_on_listing_id"
    t.check_constraint "currency::text ~ '^[A-Z]{3}$'::text", name: "chk_cart_items_currency"
    t.check_constraint "quantity > 0", name: "chk_cart_items_quantity"
    t.check_constraint "unit_price >= 0::numeric", name: "chk_cart_items_unit_price"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.datetime "discarded_at"
    t.datetime "expires_at"
    t.text "notes"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_carts_on_account_id"
    t.index ["account_id"], name: "index_carts_one_active_per_account", unique: true, where: "((status = 0) AND (discarded_at IS NULL))"
    t.index ["created_by_id"], name: "index_carts_on_created_by_id"
    t.index ["discarded_at"], name: "index_carts_on_discarded_at", where: "(discarded_at IS NOT NULL)"
    t.index ["expires_at"], name: "index_carts_on_expires_at", where: "(expires_at IS NOT NULL)"
    t.index ["status"], name: "index_carts_on_status"
    t.check_constraint "currency::text ~ '^[A-Z]{3}$'::text", name: "chk_carts_currency"
  end

  create_table "categories", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "ancestry"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon"
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_categories_on_active"
    t.index ["ancestry", "position"], name: "index_categories_on_ancestry_position"
    t.index ["ancestry"], name: "index_categories_on_ancestry"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "cities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "latitude", precision: 10, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.string "name", null: false
    t.bigint "state_id", null: false
    t.datetime "updated_at", null: false
    t.index ["latitude", "longitude"], name: "index_cities_on_coordinates", where: "((latitude IS NOT NULL) AND (longitude IS NOT NULL))"
    t.index ["name"], name: "index_cities_on_name"
    t.index ["state_id", "name"], name: "index_cities_on_state_and_name", unique: true
    t.index ["state_id"], name: "index_cities_on_state_id"
  end

  create_table "companies", force: :cascade do |t|
    t.bigint "account_id"
    t.integer "company_type", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.text "description"
    t.string "email"
    t.string "name", null: false
    t.string "phone"
    t.string "slug", null: false
    t.string "tax_number"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "verified", default: false, null: false
    t.datetime "verified_at"
    t.string "website"
    t.index ["account_id"], name: "index_companies_on_account_id"
    t.index ["created_by_id"], name: "index_companies_on_created_by_id", where: "(created_by_id IS NOT NULL)"
    t.index ["slug"], name: "index_companies_on_slug", unique: true
    t.index ["user_id"], name: "index_companies_on_user_id"
    t.index ["verified"], name: "index_companies_on_verified_true", where: "(verified = true)"
    t.check_constraint "verified = false AND verified_at IS NULL OR verified = true AND verified_at IS NOT NULL", name: "chk_companies_verified_at_consistency"
  end

  create_table "conversation_participants", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "joined_at", null: false
    t.bigint "last_read_message_id"
    t.datetime "left_at"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["conversation_id", "user_id"], name: "index_conv_participants_on_conv_and_user", unique: true
    t.index ["conversation_id"], name: "index_conversation_participants_on_conversation_id"
    t.index ["last_read_message_id"], name: "index_conv_participants_on_last_read_message", where: "(last_read_message_id IS NOT NULL)"
    t.index ["user_id"], name: "index_conv_participants_on_user_id"
    t.index ["user_id"], name: "index_conversation_participants_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "listing_id"
    t.string "subject", limit: 255
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_conversations_on_listing_id"
    t.index ["listing_id"], name: "index_conversations_on_listing_id_present", where: "(listing_id IS NOT NULL)"
    t.index ["updated_at"], name: "index_conversations_on_updated_at"
  end

  create_table "countries", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "continent"
    t.datetime "created_at", null: false
    t.string "currency_code", limit: 3
    t.string "currency_symbol"
    t.integer "display_order", default: 999, null: false
    t.string "flag_emoji", limit: 8
    t.string "iso2", limit: 2, null: false
    t.string "iso3", limit: 3, null: false
    t.string "locale_code"
    t.string "name", null: false
    t.string "phone_code"
    t.string "timezone"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_countries_on_active"
    t.index ["continent"], name: "index_countries_on_continent"
    t.index ["display_order"], name: "index_countries_on_display_order"
    t.index ["iso2"], name: "index_countries_on_iso2", unique: true
    t.index ["iso3"], name: "index_countries_on_iso3", unique: true
    t.index ["name"], name: "index_countries_on_name", unique: true
    t.check_constraint "continent IS NULL OR (continent::text = ANY (ARRAY['Africa'::character varying, 'Antarctica'::character varying, 'Asia'::character varying, 'Europe'::character varying, 'North America'::character varying, 'Oceania'::character varying, 'South America'::character varying]::text[]))", name: "chk_countries_continent"
    t.check_constraint "iso2::text ~ '^[A-Z]{2}$'::text", name: "chk_countries_iso2_format"
    t.check_constraint "iso3::text ~ '^[A-Z]{3}$'::text", name: "chk_countries_iso3_format"
  end

  create_table "coupon_redemptions", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "coupon_id", null: false
    t.datetime "created_at", null: false
    t.decimal "discount_applied", precision: 12, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_coupon_redemptions_on_account_id"
    t.index ["coupon_id", "account_id"], name: "index_coupon_redemptions_on_coupon_and_account", unique: true
    t.index ["coupon_id"], name: "index_coupon_redemptions_on_coupon_id"
    t.check_constraint "discount_applied > 0::numeric", name: "chk_coupon_redemptions_discount"
  end

  create_table "coupons", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "currency", limit: 3
    t.text "description"
    t.integer "discount_type", default: 0, null: false
    t.decimal "discount_value", precision: 10, scale: 2, null: false
    t.datetime "expires_at"
    t.integer "max_redemptions"
    t.string "name", null: false
    t.integer "redemptions_count", default: 0, null: false
    t.bigint "subscription_plan_id"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_coupons_on_active"
    t.index ["code"], name: "index_coupons_on_code", unique: true
    t.index ["expires_at"], name: "index_coupons_on_expires_at", where: "(expires_at IS NOT NULL)"
    t.index ["subscription_plan_id"], name: "index_coupons_on_subscription_plan_id", where: "(subscription_plan_id IS NOT NULL)"
    t.check_constraint "discount_type <> 0 OR discount_value > 0::numeric AND discount_value <= 100::numeric", name: "chk_coupons_percentage_range"
    t.check_constraint "discount_value > 0::numeric", name: "chk_coupons_discount_value"
    t.check_constraint "redemptions_count >= 0", name: "chk_coupons_redemptions_count"
  end

  create_table "currencies", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", limit: 3, null: false
    t.datetime "created_at", null: false
    t.decimal "exchange_rate", precision: 18, scale: 8, default: "1.0", null: false
    t.datetime "exchange_rate_updated_at"
    t.boolean "is_default", default: false, null: false
    t.string "name", null: false
    t.string "symbol", limit: 10, null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_currencies_active", where: "(active = true)"
    t.index ["code"], name: "index_currencies_on_code", unique: true
    t.index ["is_default"], name: "index_currencies_on_default_unique", unique: true, where: "(is_default = true)"
    t.check_constraint "code::text ~ '^[A-Z]{3}$'::text", name: "chk_currencies_code"
    t.check_constraint "exchange_rate > 0::numeric", name: "chk_currencies_exchange_rate"
  end

  create_table "favorites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "listing_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["listing_id"], name: "index_favorites_on_listing_id"
    t.index ["user_id", "listing_id"], name: "index_favorites_on_user_and_listing", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "invoice_items", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.string "description", null: false
    t.bigint "invoice_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "unit_price", precision: 12, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_items_on_invoice_id"
    t.check_constraint "amount >= 0::numeric", name: "chk_invoice_items_amount"
    t.check_constraint "currency::text ~ '^[A-Z]{3}$'::text", name: "chk_invoice_items_currency"
    t.check_constraint "quantity > 0", name: "chk_invoice_items_quantity"
    t.check_constraint "unit_price >= 0::numeric", name: "chk_invoice_items_unit_price"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "account_subscription_id"
    t.datetime "created_at", null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.decimal "discount_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "due_at"
    t.string "invoice_number", null: false
    t.jsonb "metadata", default: {}, null: false
    t.text "notes"
    t.datetime "paid_at"
    t.string "provider_invoice_id"
    t.integer "status", default: 0, null: false
    t.bigint "subscription_plan_id"
    t.decimal "subtotal", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "tax_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "status"], name: "index_invoices_on_account_and_status"
    t.index ["account_id"], name: "index_invoices_on_account_id"
    t.index ["account_subscription_id"], name: "index_invoices_on_account_subscription_id", where: "(account_subscription_id IS NOT NULL)"
    t.index ["due_at"], name: "index_invoices_on_due_at_open", where: "((due_at IS NOT NULL) AND (status = 1))"
    t.index ["invoice_number"], name: "index_invoices_on_invoice_number", unique: true
    t.index ["provider_invoice_id"], name: "index_invoices_on_provider_invoice_id", unique: true, where: "(provider_invoice_id IS NOT NULL)"
    t.check_constraint "currency::text ~ '^[A-Z]{3}$'::text", name: "chk_invoices_currency"
    t.check_constraint "discount_amount >= 0::numeric", name: "chk_invoices_discount"
    t.check_constraint "subtotal >= 0::numeric", name: "chk_invoices_subtotal"
    t.check_constraint "tax_amount >= 0::numeric", name: "chk_invoices_tax"
    t.check_constraint "total >= 0::numeric", name: "chk_invoices_total"
  end

  create_table "listings", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "brand_id", null: false
    t.bigint "category_id", null: false
    t.integer "condition", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.text "description", null: false
    t.boolean "featured", default: false, null: false
    t.integer "listing_type", default: 0, null: false
    t.bigint "location_city_id"
    t.decimal "price", precision: 12, scale: 2, null: false
    t.boolean "price_negotiable", default: false, null: false
    t.bigint "printer_model_id"
    t.datetime "published_at"
    t.integer "quantity", default: 1, null: false
    t.string "slug", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "views_count", default: 0, null: false
    t.integer "year"
    t.index ["account_id", "status"], name: "index_listings_on_account_and_status", where: "(account_id IS NOT NULL)"
    t.index ["brand_id", "status"], name: "index_listings_on_brand_and_status"
    t.index ["brand_id"], name: "index_listings_on_brand_id"
    t.index ["category_id", "status"], name: "index_listings_on_category_and_status"
    t.index ["category_id"], name: "index_listings_on_category_id"
    t.index ["featured"], name: "index_listings_on_featured"
    t.index ["listing_type", "status"], name: "index_listings_on_type_and_status"
    t.index ["location_city_id", "status"], name: "index_listings_on_city_and_status", where: "(location_city_id IS NOT NULL)"
    t.index ["location_city_id"], name: "index_listings_on_location_city_id", where: "(location_city_id IS NOT NULL)"
    t.index ["price"], name: "index_listings_on_price"
    t.index ["printer_model_id"], name: "index_listings_on_printer_model_id", where: "(printer_model_id IS NOT NULL)"
    t.index ["published_at"], name: "index_listings_on_published_at", where: "(published_at IS NOT NULL)"
    t.index ["slug"], name: "index_listings_on_slug", unique: true
    t.index ["status"], name: "index_listings_on_status"
    t.index ["title"], name: "index_listings_on_title_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["user_id", "status"], name: "index_listings_on_user_and_status"
    t.index ["user_id"], name: "index_listings_on_user_id"
    t.check_constraint "(status <> ALL (ARRAY[1, 2])) OR published_at IS NOT NULL", name: "chk_listings_published_at_when_live"
    t.check_constraint "currency::text ~ '^[A-Z]{3}$'::text", name: "chk_listings_currency_format"
    t.check_constraint "price > 0::numeric", name: "chk_listings_price_positive"
    t.check_constraint "quantity >= 0", name: "chk_listings_quantity_non_negative"
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "accepted_at"
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.integer "role", default: 0, null: false
    t.string "title", limit: 100
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["account_id", "role"], name: "index_memberships_on_account_and_role"
    t.index ["account_id", "user_id"], name: "index_memberships_on_account_and_user_active", unique: true, where: "(discarded_at IS NULL)"
    t.index ["account_id"], name: "index_memberships_on_account_id"
    t.index ["discarded_at"], name: "index_memberships_on_discarded_at", where: "(discarded_at IS NOT NULL)"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.datetime "edited_at"
    t.datetime "read_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["conversation_id", "created_at"], name: "index_messages_on_conversation_and_created_at"
    t.index ["conversation_id", "read_at"], name: "index_messages_on_conversation_id_unread", where: "(read_at IS NULL)"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.jsonb "data", default: {}, null: false
    t.bigint "notifiable_id"
    t.string "notifiable_type"
    t.string "notification_type", null: false
    t.datetime "read_at"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["data"], name: "index_notifications_on_data_gin", using: :gin
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable", where: "(notifiable_type IS NOT NULL)"
    t.index ["user_id", "created_at"], name: "index_notifications_on_user_and_created_at"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_unread", where: "(read_at IS NULL)"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "offers", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.bigint "buyer_id", null: false
    t.datetime "created_at", null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.datetime "expires_at"
    t.bigint "listing_id", null: false
    t.text "message"
    t.bigint "parent_offer_id"
    t.bigint "proposed_by_id", null: false
    t.bigint "seller_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_id", "status"], name: "index_offers_on_buyer_and_status"
    t.index ["expires_at"], name: "index_offers_on_expires_at_pending", where: "((expires_at IS NOT NULL) AND (status = 0))"
    t.index ["listing_id", "status"], name: "index_offers_on_listing_and_status"
    t.index ["listing_id"], name: "index_offers_on_listing_id"
    t.index ["parent_offer_id"], name: "index_offers_on_parent_offer_id", where: "(parent_offer_id IS NOT NULL)"
    t.index ["seller_id", "status"], name: "index_offers_on_seller_and_status"
    t.check_constraint "amount > 0::numeric", name: "chk_offers_amount_positive"
    t.check_constraint "buyer_id <> seller_id", name: "chk_offers_buyer_not_seller"
    t.check_constraint "currency::text ~ '^[A-Z]{3}$'::text", name: "chk_offers_currency_format"
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.decimal "discount_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.bigint "listing_id"
    t.jsonb "listing_snapshot"
    t.bigint "order_id", null: false
    t.integer "quantity", default: 1, null: false
    t.bigint "seller_account_id"
    t.decimal "tax_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "tax_rate_applied", precision: 8, scale: 6, default: "0.0", null: false
    t.decimal "total", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "unit_price", precision: 12, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_order_items_on_listing_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["seller_account_id"], name: "index_order_items_on_seller_account_id"
    t.check_constraint "currency::text ~ '^[A-Z]{3}$'::text", name: "chk_order_items_currency"
    t.check_constraint "discount_amount >= 0::numeric", name: "chk_order_items_discount"
    t.check_constraint "quantity > 0", name: "chk_order_items_quantity"
    t.check_constraint "tax_amount >= 0::numeric", name: "chk_order_items_tax_amount"
    t.check_constraint "total >= 0::numeric", name: "chk_order_items_total"
    t.check_constraint "unit_price >= 0::numeric", name: "chk_order_items_unit_price"
  end

  create_table "order_status_histories", force: :cascade do |t|
    t.bigint "changed_by_id"
    t.datetime "created_at", null: false
    t.integer "from_status"
    t.text "note"
    t.bigint "order_id", null: false
    t.string "source", limit: 50, default: "system", null: false
    t.integer "to_status", null: false
    t.index ["changed_by_id"], name: "index_order_status_histories_on_changed_by_id"
    t.index ["order_id", "created_at"], name: "index_order_status_histories_on_order_and_time"
    t.index ["order_id"], name: "index_order_status_histories_on_order_id"
    t.check_constraint "source::text = ANY (ARRAY['system'::character varying, 'user'::character varying, 'webhook'::character varying, 'admin'::character varying]::text[])", name: "chk_order_status_histories_source"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "billing_address_id"
    t.jsonb "billing_address_snapshot"
    t.bigint "buyer_account_id", null: false
    t.text "cancellation_reason"
    t.datetime "cancelled_at"
    t.bigint "cancelled_by_id"
    t.datetime "completed_at"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.datetime "delivered_at"
    t.decimal "discount_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.text "internal_notes"
    t.jsonb "metadata"
    t.text "notes"
    t.string "order_number", null: false
    t.datetime "paid_at"
    t.bigint "seller_account_id", null: false
    t.datetime "shipped_at"
    t.bigint "shipping_address_id"
    t.jsonb "shipping_address_snapshot"
    t.decimal "shipping_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "status", default: 0, null: false
    t.decimal "subtotal", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "tax_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["billing_address_id"], name: "index_orders_on_billing_address", where: "(billing_address_id IS NOT NULL)"
    t.index ["buyer_account_id", "status"], name: "index_orders_on_buyer_and_status"
    t.index ["buyer_account_id"], name: "index_orders_on_buyer_account_id"
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["created_by_id"], name: "index_orders_on_created_by_id"
    t.index ["order_number"], name: "index_orders_on_order_number", unique: true
    t.index ["paid_at"], name: "index_orders_on_paid_at", where: "(paid_at IS NOT NULL)"
    t.index ["seller_account_id", "status"], name: "index_orders_on_seller_and_status"
    t.index ["seller_account_id"], name: "index_orders_on_seller_account_id"
    t.index ["shipping_address_id"], name: "index_orders_on_shipping_address", where: "(shipping_address_id IS NOT NULL)"
    t.index ["status"], name: "index_orders_on_status"
    t.check_constraint "buyer_account_id <> seller_account_id", name: "chk_orders_buyer_seller_different"
    t.check_constraint "currency::text ~ '^[A-Z]{3}$'::text", name: "chk_orders_currency"
    t.check_constraint "discount_amount >= 0::numeric", name: "chk_orders_discount_amount"
    t.check_constraint "shipping_amount >= 0::numeric", name: "chk_orders_shipping_amount"
    t.check_constraint "subtotal >= 0::numeric", name: "chk_orders_subtotal"
    t.check_constraint "tax_amount >= 0::numeric", name: "chk_orders_tax_amount"
    t.check_constraint "total >= 0::numeric", name: "chk_orders_total"
  end

  create_table "payment_transactions", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.string "gateway", limit: 50, null: false
    t.text "gateway_message"
    t.jsonb "gateway_response"
    t.string "gateway_transaction_id", limit: 255
    t.bigint "payment_id", null: false
    t.datetime "processed_at"
    t.integer "status", default: 0, null: false
    t.string "transaction_type", limit: 30, null: false
    t.datetime "updated_at", null: false
    t.index ["gateway", "gateway_transaction_id"], name: "index_payment_transactions_on_gateway_txn_id", unique: true, where: "(gateway_transaction_id IS NOT NULL)"
    t.index ["payment_id"], name: "index_payment_transactions_on_payment_id"
    t.index ["status"], name: "index_payment_transactions_on_status"
    t.check_constraint "amount > 0::numeric", name: "chk_payment_transactions_amount"
    t.check_constraint "currency::text ~ '^[A-Z]{3}$'::text", name: "chk_payment_transactions_currency"
    t.check_constraint "transaction_type::text = ANY (ARRAY['charge'::character varying, 'authorize'::character varying, 'capture'::character varying, 'refund'::character varying, 'void'::character varying]::text[])", name: "chk_payment_transactions_type"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.text "failure_reason"
    t.bigint "invoice_id"
    t.jsonb "metadata", default: {}, null: false
    t.bigint "order_id"
    t.datetime "paid_at"
    t.integer "payment_context", default: 0, null: false
    t.string "payment_method"
    t.string "payment_provider"
    t.string "provider_payment_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "status"], name: "index_payments_on_account_and_status"
    t.index ["account_id"], name: "index_payments_on_account_id"
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["paid_at"], name: "index_payments_on_paid_at", where: "(paid_at IS NOT NULL)"
    t.index ["payment_context"], name: "index_payments_on_payment_context"
    t.index ["provider_payment_id"], name: "index_payments_on_provider_payment_id", unique: true, where: "(provider_payment_id IS NOT NULL)"
    t.check_constraint "amount > 0::numeric", name: "chk_payments_amount"
    t.check_constraint "currency::text ~ '^[A-Z]{3}$'::text", name: "chk_payments_currency"
  end

  create_table "plan_features", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "display_name", null: false
    t.string "feature_key", null: false
    t.string "feature_type", default: "boolean", null: false
    t.bigint "subscription_plan_id", null: false
    t.datetime "updated_at", null: false
    t.string "value", null: false
    t.index ["subscription_plan_id", "feature_key"], name: "index_plan_features_on_plan_and_key", unique: true
    t.index ["subscription_plan_id"], name: "index_plan_features_on_subscription_plan_id"
    t.check_constraint "feature_type::text = ANY (ARRAY['boolean'::character varying, 'limit'::character varying, 'string'::character varying]::text[])", name: "chk_plan_features_feature_type"
  end

  create_table "printer_models", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "discontinued", default: false, null: false
    t.string "model_number"
    t.string "name", null: false
    t.integer "release_year"
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id", "name"], name: "index_printer_models_on_brand_and_name", unique: true
    t.index ["brand_id"], name: "index_printer_models_on_brand_id"
    t.index ["category_id"], name: "index_printer_models_on_category_id", where: "(category_id IS NOT NULL)"
    t.index ["discontinued"], name: "index_printer_models_on_discontinued"
    t.index ["slug"], name: "index_printer_models_on_slug", unique: true
  end

  create_table "profiles", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "locale", limit: 10, default: "en", null: false
    t.string "phone"
    t.string "timezone", limit: 64, default: "UTC", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["phone"], name: "index_profiles_on_phone", where: "(phone IS NOT NULL)"
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "reviews", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.bigint "listing_id", null: false
    t.integer "rating", null: false
    t.bigint "reviewee_id", null: false
    t.bigint "reviewer_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id", "reviewer_id"], name: "index_reviews_on_listing_and_reviewer", unique: true
    t.index ["listing_id"], name: "index_reviews_on_listing_id"
    t.index ["reviewee_id", "status"], name: "index_reviews_on_reviewee_and_status"
    t.index ["status"], name: "index_reviews_on_status"
    t.check_constraint "rating >= 1 AND rating <= 5", name: "chk_reviews_rating_range"
    t.check_constraint "reviewer_id <> reviewee_id", name: "chk_reviews_no_self_review"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
    t.index ["slug"], name: "index_roles_on_slug", unique: true
  end

  create_table "saved_searches", force: :cascade do |t|
    t.boolean "alert_enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.jsonb "filters", default: {}, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["filters"], name: "index_saved_searches_on_filters_gin", using: :gin
    t.index ["user_id"], name: "index_saved_searches_on_user_id"
    t.index ["user_id"], name: "index_saved_searches_on_user_id_alerts", where: "(alert_enabled = true)"
  end

  create_table "shipment_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_item_id", null: false
    t.integer "quantity", default: 1, null: false
    t.bigint "shipment_id", null: false
    t.datetime "updated_at", null: false
    t.index ["order_item_id"], name: "index_shipment_items_on_order_item_id"
    t.index ["shipment_id", "order_item_id"], name: "index_shipment_items_on_shipment_and_order_item", unique: true
    t.index ["shipment_id"], name: "index_shipment_items_on_shipment_id"
    t.check_constraint "quantity > 0", name: "chk_shipment_items_quantity"
  end

  create_table "shipments", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "carrier", limit: 100
    t.datetime "created_at", null: false
    t.string "currency", limit: 3, default: "USD"
    t.datetime "delivered_at"
    t.datetime "estimated_delivery_at"
    t.jsonb "metadata"
    t.text "notes"
    t.bigint "order_id", null: false
    t.datetime "shipped_at"
    t.decimal "shipping_cost", precision: 12, scale: 2
    t.integer "status", default: 0, null: false
    t.string "tracking_number", limit: 100
    t.datetime "updated_at", null: false
    t.decimal "weight", precision: 10, scale: 3
    t.string "weight_unit", limit: 5, default: "kg"
    t.index ["account_id", "status"], name: "index_shipments_on_account_and_status"
    t.index ["account_id"], name: "index_shipments_on_account_id"
    t.index ["order_id"], name: "index_shipments_on_order_id"
    t.index ["status"], name: "index_shipments_on_status"
    t.index ["tracking_number"], name: "index_shipments_on_tracking_number", unique: true, where: "(tracking_number IS NOT NULL)"
    t.check_constraint "shipping_cost IS NULL OR shipping_cost >= 0::numeric", name: "chk_shipments_shipping_cost"
    t.check_constraint "weight IS NULL OR weight > 0::numeric", name: "chk_shipments_weight"
    t.check_constraint "weight_unit::text = ANY (ARRAY['kg'::character varying, 'lb'::character varying, 'oz'::character varying, 'g'::character varying]::text[])", name: "chk_shipments_weight_unit"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.binary "key", null: false
    t.bigint "key_hash", null: false
    t.binary "value", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "states", force: :cascade do |t|
    t.string "code", limit: 10
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id", "code"], name: "index_states_on_country_and_code", unique: true, where: "(code IS NOT NULL)"
    t.index ["country_id", "name"], name: "index_states_on_country_and_name", unique: true
    t.index ["country_id"], name: "index_states_on_country_id"
    t.index ["name"], name: "index_states_on_name"
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.text "description"
    t.jsonb "metadata", default: {}, null: false
    t.decimal "monthly_price", precision: 10, scale: 2, default: "0.0", null: false
    t.string "name", null: false
    t.integer "plan_type", default: 0, null: false
    t.integer "priority", default: 0, null: false
    t.string "slug", null: false
    t.integer "trial_days", default: 0, null: false
    t.boolean "trial_eligible", default: false, null: false
    t.datetime "updated_at", null: false
    t.decimal "yearly_price", precision: 10, scale: 2, default: "0.0", null: false
    t.index ["active"], name: "index_subscription_plans_on_active"
    t.index ["priority"], name: "index_subscription_plans_on_priority"
    t.index ["slug"], name: "index_subscription_plans_on_slug", unique: true
    t.check_constraint "currency::text ~ '^[A-Z]{3}$'::text", name: "chk_subscription_plans_currency"
    t.check_constraint "monthly_price >= 0::numeric", name: "chk_subscription_plans_monthly_price"
    t.check_constraint "priority >= 0", name: "chk_subscription_plans_priority"
    t.check_constraint "trial_days >= 0", name: "chk_subscription_plans_trial_days"
    t.check_constraint "yearly_price >= 0::numeric", name: "chk_subscription_plans_yearly_price"
  end

  create_table "subscription_usages", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "account_subscription_id", null: false
    t.datetime "created_at", null: false
    t.string "feature_key", null: false
    t.date "period_end"
    t.date "period_start", null: false
    t.decimal "quantity", precision: 15, scale: 3, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "feature_key", "period_start"], name: "index_subscription_usages_on_account_feature_period", unique: true
    t.index ["account_id", "period_start"], name: "index_subscription_usages_on_account_and_period"
    t.index ["account_id"], name: "index_subscription_usages_on_account_id"
    t.index ["account_subscription_id"], name: "index_subscription_usages_on_account_subscription_id"
    t.check_constraint "quantity >= 0::numeric", name: "chk_subscription_usages_quantity"
  end

  create_table "tax_rates", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "country_code", limit: 2, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.decimal "rate", precision: 8, scale: 6, null: false
    t.string "state_code", limit: 10
    t.integer "tax_type", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["country_code", "state_code", "active"], name: "index_tax_rates_on_country_state_active"
    t.index ["country_code", "state_code", "tax_type"], name: "index_tax_rates_unique_active", unique: true, where: "(active = true)"
    t.check_constraint "country_code::text ~ '^[A-Z]{2}$'::text", name: "chk_tax_rates_country_code"
    t.check_constraint "rate >= 0::numeric AND rate <= 1::numeric", name: "chk_tax_rates_rate"
  end

  create_table "user_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "account_subscriptions", "accounts", on_delete: :restrict
  add_foreign_key "account_subscriptions", "coupon_redemptions", on_delete: :nullify
  add_foreign_key "account_subscriptions", "subscription_plans", on_delete: :restrict
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "cities", on_delete: :restrict
  add_foreign_key "addresses", "countries", on_delete: :restrict
  add_foreign_key "addresses", "states", on_delete: :restrict
  add_foreign_key "cart_items", "carts", on_delete: :cascade
  add_foreign_key "cart_items", "listings", on_delete: :cascade
  add_foreign_key "cart_items", "users", column: "added_by_id", on_delete: :nullify
  add_foreign_key "carts", "accounts", on_delete: :cascade
  add_foreign_key "carts", "users", column: "created_by_id", on_delete: :cascade
  add_foreign_key "cities", "states", on_delete: :restrict
  add_foreign_key "companies", "accounts", on_delete: :restrict
  add_foreign_key "companies", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "companies", "users", on_delete: :restrict
  add_foreign_key "conversation_participants", "conversations", on_delete: :cascade
  add_foreign_key "conversation_participants", "messages", column: "last_read_message_id", on_delete: :nullify
  add_foreign_key "conversation_participants", "users", on_delete: :cascade
  add_foreign_key "conversations", "listings", on_delete: :nullify
  add_foreign_key "coupon_redemptions", "accounts", on_delete: :restrict
  add_foreign_key "coupon_redemptions", "coupons", on_delete: :restrict
  add_foreign_key "coupons", "subscription_plans", on_delete: :nullify
  add_foreign_key "favorites", "listings", on_delete: :cascade
  add_foreign_key "favorites", "users", on_delete: :cascade
  add_foreign_key "invoice_items", "invoices", on_delete: :cascade
  add_foreign_key "invoices", "account_subscriptions", on_delete: :nullify
  add_foreign_key "invoices", "accounts", on_delete: :restrict
  add_foreign_key "invoices", "subscription_plans", on_delete: :nullify
  add_foreign_key "listings", "accounts", on_delete: :restrict
  add_foreign_key "listings", "brands", on_delete: :restrict
  add_foreign_key "listings", "categories", on_delete: :restrict
  add_foreign_key "listings", "cities", column: "location_city_id", on_delete: :nullify
  add_foreign_key "listings", "printer_models", on_delete: :nullify
  add_foreign_key "listings", "users", on_delete: :restrict
  add_foreign_key "memberships", "accounts", on_delete: :cascade
  add_foreign_key "memberships", "users", on_delete: :cascade
  add_foreign_key "messages", "conversations", on_delete: :cascade
  add_foreign_key "messages", "users", on_delete: :restrict
  add_foreign_key "notifications", "users", on_delete: :cascade
  add_foreign_key "offers", "listings", on_delete: :restrict
  add_foreign_key "offers", "offers", column: "parent_offer_id", on_delete: :nullify
  add_foreign_key "offers", "users", column: "buyer_id", on_delete: :restrict
  add_foreign_key "offers", "users", column: "proposed_by_id", on_delete: :restrict
  add_foreign_key "offers", "users", column: "seller_id", on_delete: :restrict
  add_foreign_key "order_items", "accounts", column: "seller_account_id", on_delete: :nullify
  add_foreign_key "order_items", "listings", on_delete: :nullify
  add_foreign_key "order_items", "orders", on_delete: :cascade
  add_foreign_key "order_status_histories", "orders", on_delete: :cascade
  add_foreign_key "order_status_histories", "users", column: "changed_by_id", on_delete: :nullify
  add_foreign_key "orders", "accounts", column: "buyer_account_id", on_delete: :restrict
  add_foreign_key "orders", "accounts", column: "seller_account_id", on_delete: :restrict
  add_foreign_key "orders", "addresses", column: "billing_address_id", on_delete: :nullify
  add_foreign_key "orders", "addresses", column: "shipping_address_id", on_delete: :nullify
  add_foreign_key "orders", "users", column: "cancelled_by_id", on_delete: :nullify
  add_foreign_key "orders", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "payment_transactions", "payments", on_delete: :cascade
  add_foreign_key "payments", "accounts", on_delete: :restrict
  add_foreign_key "payments", "invoices", on_delete: :nullify
  add_foreign_key "payments", "orders", on_delete: :nullify
  add_foreign_key "plan_features", "subscription_plans", on_delete: :cascade
  add_foreign_key "printer_models", "brands", on_delete: :restrict
  add_foreign_key "printer_models", "categories", on_delete: :nullify
  add_foreign_key "profiles", "users", on_delete: :cascade
  add_foreign_key "reviews", "listings", on_delete: :restrict
  add_foreign_key "reviews", "users", column: "reviewee_id", on_delete: :restrict
  add_foreign_key "reviews", "users", column: "reviewer_id", on_delete: :restrict
  add_foreign_key "saved_searches", "users", on_delete: :cascade
  add_foreign_key "shipment_items", "order_items", on_delete: :restrict
  add_foreign_key "shipment_items", "shipments", on_delete: :cascade
  add_foreign_key "shipments", "accounts", on_delete: :restrict
  add_foreign_key "shipments", "orders", on_delete: :restrict
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "states", "countries", on_delete: :restrict
  add_foreign_key "subscription_usages", "account_subscriptions", on_delete: :cascade
  add_foreign_key "subscription_usages", "accounts", on_delete: :cascade
  add_foreign_key "user_roles", "roles", on_delete: :cascade
  add_foreign_key "user_roles", "users", on_delete: :cascade
end
