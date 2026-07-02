module Portal
  module Seller
    class DashboardController < Portal::BaseController
      def show
        account  = Current.account
        listings = account.listings.kept

        @stats = {
          total_listings:     listings.count,
          published:          listings.published.count,
          draft:              listings.draft.count,
          paused:             listings.paused.count,
          sold:               listings.sold.count,
          total_views:        listings.sum(:views_count),
          total_favorites:    Favorite.where(listing: listings).count
        }

        @recent_listings = listings
                             .includes(:category, :brand)
                             .order(updated_at: :desc)
                             .limit(5)

        @top_listings = listings.published
                                .includes(:category, :brand)
                                .order(views_count: :desc)
                                .limit(5)
      end
    end
  end
end
