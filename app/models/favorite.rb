class Favorite < ApplicationRecord
  # user    → cascade (migration): destroying a user removes their favorites
  # listing → cascade (migration): destroying a listing removes all favorites for it
  belongs_to :user
  belongs_to :listing

  validates :user_id, uniqueness: { scope: :listing_id,
                                    message: "has already saved this listing" }

  scope :recent, -> { order(created_at: :desc) }
end
