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

ActiveRecord::Schema[8.1].define(version: 2026_07_01_142505) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

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
    t.integer "company_type", default: 0, null: false
    t.datetime "created_at", null: false
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

  create_table "listings", force: :cascade do |t|
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "cities", on_delete: :restrict
  add_foreign_key "addresses", "countries", on_delete: :restrict
  add_foreign_key "addresses", "states", on_delete: :restrict
  add_foreign_key "cities", "states", on_delete: :restrict
  add_foreign_key "companies", "users", on_delete: :restrict
  add_foreign_key "conversation_participants", "conversations", on_delete: :cascade
  add_foreign_key "conversation_participants", "messages", column: "last_read_message_id", on_delete: :nullify
  add_foreign_key "conversation_participants", "users", on_delete: :cascade
  add_foreign_key "conversations", "listings", on_delete: :nullify
  add_foreign_key "favorites", "listings", on_delete: :cascade
  add_foreign_key "favorites", "users", on_delete: :cascade
  add_foreign_key "listings", "brands", on_delete: :restrict
  add_foreign_key "listings", "categories", on_delete: :restrict
  add_foreign_key "listings", "cities", column: "location_city_id", on_delete: :nullify
  add_foreign_key "listings", "printer_models", on_delete: :nullify
  add_foreign_key "listings", "users", on_delete: :restrict
  add_foreign_key "messages", "conversations", on_delete: :cascade
  add_foreign_key "messages", "users", on_delete: :restrict
  add_foreign_key "notifications", "users", on_delete: :cascade
  add_foreign_key "offers", "listings", on_delete: :restrict
  add_foreign_key "offers", "offers", column: "parent_offer_id", on_delete: :nullify
  add_foreign_key "offers", "users", column: "buyer_id", on_delete: :restrict
  add_foreign_key "offers", "users", column: "proposed_by_id", on_delete: :restrict
  add_foreign_key "offers", "users", column: "seller_id", on_delete: :restrict
  add_foreign_key "printer_models", "brands", on_delete: :restrict
  add_foreign_key "printer_models", "categories", on_delete: :nullify
  add_foreign_key "profiles", "users", on_delete: :cascade
  add_foreign_key "reviews", "listings", on_delete: :restrict
  add_foreign_key "reviews", "users", column: "reviewee_id", on_delete: :restrict
  add_foreign_key "reviews", "users", column: "reviewer_id", on_delete: :restrict
  add_foreign_key "saved_searches", "users", on_delete: :cascade
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "states", "countries", on_delete: :restrict
  add_foreign_key "user_roles", "roles", on_delete: :cascade
  add_foreign_key "user_roles", "users", on_delete: :cascade
end
