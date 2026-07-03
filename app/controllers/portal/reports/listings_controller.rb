module Portal
  module Reports
    class ListingsController < BaseController
      def show
        base = Listing.kept.where(account: Current.account)

        @summary = {
          total:      base.count,
          published:  base.where(status: "published").count,
          draft:      base.where(status: "draft").count,
          sold:       base.where(status: "sold").count,
          total_views: base.sum(:views_count)
        }

        @top_by_views = base.where(status: "published")
                            .order(views_count: :desc)
                            .includes(:category, :brand)
                            .limit(15)

        @top_by_favorites = base
                              .joins(:favorites)
                              .where(favorites: { created_at: @from..@to })
                              .group("listings.id", "listings.title", "listings.views_count", "listings.price", "listings.currency")
                              .select("listings.id, listings.title, listings.views_count, listings.price, listings.currency, COUNT(favorites.id) AS fav_count")
                              .order("fav_count DESC")
                              .limit(10)

        @by_category = base.joins(:category)
                           .group("categories.name")
                           .count
                           .sort_by { |_, v| -v }
                           .first(8)
      end
    end
  end
end
