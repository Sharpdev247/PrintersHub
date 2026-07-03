# Favorites — bookmarked listings per user.
#
# FK strategies:
#   user    → CASCADE : deleting a user removes their favorites (no orphans)
#   listing → CASCADE : deleting a listing clears all related favorites
#
# Composite unique index enforces one favorite per user/listing at the DB level.
# Both individual FK indexes (user_id, listing_id) are created automatically by
# t.references; no extra add_index needed for them.
class CreateFavorites < ActiveRecord::Migration[8.1]
  def change
    create_table :favorites do |t|
      t.references :user,    null: false, foreign_key: { on_delete: :cascade }
      t.references :listing, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end

    # DB-level uniqueness guard — model validates this too, but the DB is the hard stop.
    add_index :favorites, [ :user_id, :listing_id ], unique: true,
              name: "index_favorites_on_user_and_listing"
  end
end
