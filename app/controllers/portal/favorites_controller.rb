module Portal
  class FavoritesController < Portal::BaseController
    def index
      @favorites = current_user.favorites
                               .includes(listing: [:account, :category, :brand])
                               .recent
                               .page(params[:page]).per(24)
    end
  end
end
