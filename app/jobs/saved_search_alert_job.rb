# Checks saved searches with alert_enabled and notifies users when new
# listings match their saved filters. Run periodically via Solid Queue cron.
#
# Schedule via config/recurring.yml (Solid Queue):
#   saved_search_alerts:
#     class: SavedSearchAlertJob
#     schedule: every 6 hours
class SavedSearchAlertJob < ApplicationJob
  queue_as :default

  def perform
    SavedSearch.where(alert_enabled: true).find_each do |saved_search|
      check_and_notify(saved_search)
    end
  end

  private

  def check_and_notify(saved_search)
    user = saved_search.user
    return unless user

    since = saved_search.last_alerted_at || 24.hours.ago
    filters = saved_search.filters.with_indifferent_access

    listings = Listing.kept.published.where("listings.created_at > ?", since)

    listings = listings.where(listing_type: filters[:type])         if filters[:type].present?
    listings = listings.where(category_id: filters[:category_id])  if filters[:category_id].present?
    listings = listings.where(brand_id:    filters[:brand_id])     if filters[:brand_id].present?
    listings = listings.where("price <= ?", filters[:price_max])   if filters[:price_max].present?
    listings = listings.where("price >= ?", filters[:price_min])   if filters[:price_min].present?

    count = listings.count
    return unless count > 0

    Notification.deliver(
      user:  user,
      type:  "listing_published",
      title: "#{count} new #{count == 1 ? 'listing' : 'listings'} match \"#{saved_search.name}\"",
      body:  "#{count} new #{count == 1 ? 'result' : 'results'} match your saved search.",
      data:  { saved_search_id: saved_search.id, count: count, filters: filters }
    )

    saved_search.update_column(:last_alerted_at, Time.current)
  rescue => e
    Rails.logger.error("[SavedSearchAlertJob] Error for saved_search #{saved_search.id}: #{e.message}")
  end
end
