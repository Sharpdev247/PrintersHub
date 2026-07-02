class FavoritesController < ApplicationController
  before_action :authenticate_user!

  # POST /listings/:listing_id/favorite  — toggle save/unsave
  def create
    listing  = Listing.kept.friendly.find(params[:listing_id])
    favorite = current_user.favorites.find_by(listing: listing)

    if favorite
      favorite.destroy
      saved = false
    else
      current_user.favorites.create!(listing: listing)
      saved = true
    end

    respond_to do |format|
      format.html { redirect_back fallback_location: listing_path(listing) }
      format.json { render json: { saved: saved, count: listing.favorites.count } }
    end
  end
end
