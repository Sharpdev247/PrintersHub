# SavedSearches — reusable search filter presets per user.
#
# Why JSONB for filters instead of individual columns?
#   1. Filter criteria evolve without schema migrations — adding brand_ids, price_max,
#      condition, featured, seller_type etc. requires no ALTER TABLE.
#   2. JSONB is queryable: WHERE filters @> '{"brand_id": 1}' works at the DB level.
#   3. GIN index on filters enables efficient containment queries for future
#      alert delivery ("find all saved searches that match this new listing").
#
# FK strategy:
#   user → CASCADE : deleting a user removes their saved searches.
class CreateSavedSearches < ActiveRecord::Migration[8.1]
  def change
    create_table :saved_searches do |t|
      t.references :user,  null: false, foreign_key: { on_delete: :cascade }
      t.string  :name,           null: false
      t.jsonb   :filters,        null: false, default: {}
      t.boolean :alert_enabled,  null: false, default: false
      t.timestamps
    end

    # Enables efficient WHERE filters @> '{"brand_id": 5}' containment queries
    # used by future alert delivery background jobs.
    add_index :saved_searches, :filters, using: :gin,
              name: "index_saved_searches_on_filters_gin"

    # Most queries are scoped to a user — cover the user lookup.
    # (t.references :user auto-creates a simple user_id index; this partial one is
    #  an additional covering index for alert-enabled queries only.)
    add_index :saved_searches, :user_id, where: "alert_enabled = TRUE",
              name: "index_saved_searches_on_user_id_alerts"
  end
end
