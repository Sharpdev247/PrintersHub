class Api::V1::AiController < Api::V1::BaseController
  # POST /api/v1/ai/describe
  # Generates a listing description from attributes.
  # Requires scope: write:listings
  def describe
    require_scope! "write:listings"

    attrs = params.require(:listing).permit(
      :title, :category, :brand, :condition, :listing_type, :price, :currency, :notes,
      printer_models: []
    ).to_h.symbolize_keys

    description = Ai::ListingDescriptionService.call(attrs)

    if description
      render json: { description: description }
    else
      render json: { error: "AI service unavailable." }, status: :service_unavailable
    end
  end

  # POST /api/v1/ai/price
  # Suggests a price range for a listing.
  # Requires scope: write:listings
  def price
    require_scope! "write:listings"

    attrs = params.require(:listing).permit(
      :title, :category, :brand, :condition, printer_models: []
    ).to_h.symbolize_keys

    comparables = Listing.kept
      .where(account: current_account, status: "sold")
      .where("LOWER(title) LIKE ?", "%#{attrs[:title].to_s.split.first.to_s.downcase}%")
      .order(updated_at: :desc)
      .limit(10)
      .map { |l| { title: l.title, condition: l.condition, price: l.price, currency: l.currency } }

    suggestion = Ai::PriceSuggestionService.call(attrs, comparable_listings: comparables)

    if suggestion
      render json: suggestion
    else
      render json: { error: "AI service unavailable." }, status: :service_unavailable
    end
  end

  # POST /api/v1/ai/search
  # Expands a natural-language query into structured filters.
  def search
    require_scope! "read:listings"

    query = params.require(:q)
    result = Ai::SearchExpanderService.call(query)

    if result
      render json: result
    else
      render json: { error: "AI service unavailable." }, status: :service_unavailable
    end
  end
end
