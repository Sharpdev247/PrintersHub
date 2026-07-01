# Reviews — post-transaction feedback between buyer and seller.
#
# Why reviewer_id and reviewee_id are separate bigint columns (not t.references):
#   Both reference the users table but represent different roles. Using t.references
#   twice with different names requires explicit FK declarations anyway. Explicit
#   bigints with manual FKs make the intent clearer.
#
# status enum: 0=pending, 1=published, 2=rejected
#   Reviews are moderated before going public. This prevents spam/abuse and is
#   standard practice on marketplaces (Airbnb, eBay, Amazon all do this).
#
# FK strategies:
#   listing  → RESTRICT : listing is the evidence of the transaction; preserve it
#   reviewer → RESTRICT : user deletion needs explicit admin action, not cascade
#   reviewee → RESTRICT : same reasoning
#
# DB constraints enforce:
#   1. reviewer cannot review themselves (chk_reviews_no_self_review)
#   2. rating must be 1–5 (chk_reviews_rating_range)
#   3. one review per listing per reviewer (unique index)
class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :listing,  null: false, foreign_key: { on_delete: :restrict }
      t.bigint     :reviewer_id, null: false
      t.bigint     :reviewee_id, null: false
      t.integer    :rating,   null: false
      t.text       :body
      t.integer    :status,   null: false, default: 0
      t.timestamps
    end

    add_foreign_key :reviews, :users, column: :reviewer_id, on_delete: :restrict
    add_foreign_key :reviews, :users, column: :reviewee_id, on_delete: :restrict

    # One review per reviewer per listing — enforced at the DB level.
    add_index :reviews, [:listing_id, :reviewer_id], unique: true,
              name: "index_reviews_on_listing_and_reviewer"

    # User profile pages: "all published reviews about this user".
    add_index :reviews, [:reviewee_id, :status],
              name: "index_reviews_on_reviewee_and_status"

    # Moderation queue: find pending reviews.
    add_index :reviews, :status,
              name: "index_reviews_on_status"

    # DB-level CHECK constraints.
    add_check_constraint :reviews, "reviewer_id <> reviewee_id",
                         name: "chk_reviews_no_self_review"
    add_check_constraint :reviews, "rating BETWEEN 1 AND 5",
                         name: "chk_reviews_rating_range"
  end
end
