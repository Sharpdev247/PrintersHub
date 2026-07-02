class ListingsController < ApplicationController
  include PublicAccessible

  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    search   = ListingSearch.new(search_params)
    base     = policy_scope(Listing)
    @sort    = search.sort_key
    @listings = search.results.merge(base).page(params[:page]).per(Settings.listings_per_page)

    authorize Listing
  end

  def show
    @listing = Listing.kept.friendly.find(params[:id])
    authorize @listing
    @listing.increment_view! if @listing.status_published?
  end

  private

  def search_params
    params.permit(:q, :type, :condition, :category_id, :brand_id,
                  :currency, :price_min, :price_max, :city_id, :sort)
  end
end
