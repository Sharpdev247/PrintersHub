module Portal
  class SavedSearchesController < Portal::BaseController
    before_action :find_saved_search, only: [:destroy, :toggle_alert]

    def index
      @saved_searches = current_user.saved_searches.recent
    end

    # POST /portal/saved_searches
    # Called from the listings search page: saves current search params as a named search.
    def create
      @saved_search = current_user.saved_searches.new(saved_search_params)

      if @saved_search.save
        redirect_to portal_saved_searches_path,
                    notice: "Search \"#{@saved_search.name}\" saved."
      else
        redirect_back fallback_location: portal_saved_searches_path,
                      alert: @saved_search.errors.full_messages.to_sentence
      end
    end

    def destroy
      @saved_search.destroy
      redirect_to portal_saved_searches_path, notice: "Saved search deleted."
    end

    # PATCH /portal/saved_searches/:id/toggle_alert
    def toggle_alert
      @saved_search.update!(alert_enabled: !@saved_search.alert_enabled)
      redirect_to portal_saved_searches_path,
                  notice: @saved_search.alert_enabled? ? "Email alerts turned on." : "Email alerts turned off."
    end

    private

    def find_saved_search
      @saved_search = current_user.saved_searches.find(params[:id])
    end

    def saved_search_params
      params.require(:saved_search).permit(
        :name, :alert_enabled,
        filters: [:q, :type, :condition, :category_id, :brand_id,
                  :currency, :price_min, :price_max, :city_id, :sort]
      )
    end
  end
end
