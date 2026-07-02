class ListingSearch
  SORT_OPTIONS = {
    "recent"      => -> (s) { s.recent },
    "price_asc"   => -> (s) { s.by_price_asc },
    "price_desc"  => -> (s) { s.by_price_desc },
    "popular"     => -> (s) { s.by_views }
  }.freeze

  DEFAULT_SORT = "recent"

  attr_reader :params

  def initialize(params = {})
    @params = params
  end

  def results
    scope = base_scope
    scope = apply_search(scope)
    scope = apply_filters(scope)
    apply_sort(scope)
  end

  def sort_key
    SORT_OPTIONS.key?(params[:sort]) ? params[:sort] : DEFAULT_SORT
  end

  private

  def base_scope
    Listing.kept
           .published
           .includes(:account, :category, :brand, :printer_model, :location_city)
  end

  def apply_search(scope)
    return scope if params[:q].blank?
    scope.search(params[:q])
  end

  def apply_filters(scope)
    scope = scope.where(listing_type: params[:type])        if params[:type].present?
    scope = scope.where(condition: params[:condition])      if params[:condition].present?
    scope = scope.where(category_id: params[:category_id]) if params[:category_id].present?
    scope = scope.where(brand_id: params[:brand_id])       if params[:brand_id].present?
    scope = scope.where(currency: params[:currency])        if params[:currency].present?

    if params[:price_min].present?
      scope = scope.where("price >= ?", params[:price_min].to_d)
    end
    if params[:price_max].present?
      scope = scope.where("price <= ?", params[:price_max].to_d)
    end

    # Location: city or state/country via join
    if params[:city_id].present?
      scope = scope.where(location_city_id: params[:city_id])
    end

    scope
  end

  def apply_sort(scope)
    sorter = SORT_OPTIONS[sort_key] || SORT_OPTIONS[DEFAULT_SORT]
    sorter.call(scope)
  end
end
