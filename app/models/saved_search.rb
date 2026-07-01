class SavedSearch < ApplicationRecord
  # user → cascade (migration): user deletion removes their saved searches
  belongs_to :user

  validates :name,    presence: true, length: { maximum: 100 }
  validates :filters, presence: true

  scope :with_alerts, -> { where(alert_enabled: true) }
  scope :recent,      -> { order(created_at: :desc) }

  # Returns all saved searches whose filters subset-match a given listing's attributes.
  # Used by background alert jobs: SavedSearch.matching_listing(listing).each { ... }
  #
  # Example filters payload:
  #   { "brand_id" => 1, "category_id" => 5, "condition" => "like_new",
  #     "price_min" => 1000, "price_max" => 50000, "listing_type" => "sale" }
  def self.matching_listing(listing)
    # JSONB containment check — find saved searches whose brand/category/condition
    # match this listing. Price range filtering is done in Ruby after the DB query
    # because JSONB range checks require more complex SQL (kept simple for MVP).
    candidates = with_alerts
                   .where("filters @> ?", { "brand_id" => listing.brand_id }.to_json)
                   .or(with_alerts.where("filters @> ?", { "category_id" => listing.category_id }.to_json))

    candidates.select do |ss|
      f = ss.filters
      price_min = f["price_min"].to_f
      price_max = f["price_max"].to_f
      price_ok = (price_min.zero? || listing.price >= price_min) &&
                 (price_max.zero? || listing.price <= price_max)
      condition_ok = f["condition"].blank? || f["condition"] == listing.condition
      price_ok && condition_ok
    end
  end
end
