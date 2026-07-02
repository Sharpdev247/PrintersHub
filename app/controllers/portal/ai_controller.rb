module Portal
  # Handles AI helper requests from the portal UI (listing form).
  # All actions respond with JSON — called via fetch() from the browser.
  class AiController < Portal::BaseController
    before_action :require_seller

    # POST /portal/ai/describe
    def describe
      attrs = params.permit(
        :title, :category, :brand, :condition, :listing_type, :notes,
        printer_models: []
      ).to_h.symbolize_keys

      result = Ai::ListingDescriptionService.call(attrs)
      if result
        render json: { description: result }
      else
        render json: { error: "AI unavailable. Please try again later." }, status: :service_unavailable
      end
    end

    # POST /portal/ai/price
    def price
      attrs = params.permit(:title, :category, :brand, :condition, printer_models: [])
                    .to_h.symbolize_keys

      comparables = Listing.kept
        .where(account: Current.account, status: "sold")
        .order(updated_at: :desc)
        .limit(10)
        .map { |l| { title: l.title, condition: l.condition, price: l.price, currency: l.currency } }

      result = Ai::PriceSuggestionService.call(attrs, comparable_listings: comparables)
      if result
        render json: result
      else
        render json: { error: "AI unavailable. Please try again later." }, status: :service_unavailable
      end
    end

    private

    def require_seller
      unless Current.role.in?(%w[owner admin manager sales_staff])
        render json: { error: "Access denied." }, status: :forbidden
      end
    end
  end
end
