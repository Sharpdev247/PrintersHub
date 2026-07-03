class Api::V1::ListingsController < Api::V1::BaseController
  before_action :set_listing, only: [ :show, :update, :destroy ]

  # GET /api/v1/listings
  def index
    require_scope! "read:listings"

    listings = policy_scope(Listing)
      .kept
      .includes(:category, :brand, :printer_models)
      .order(created_at: :desc)

    listings = listings.where(status: params[:status])           if params[:status].present?
    listings = listings.where(category_id: params[:category_id]) if params[:category_id].present?
    listings = listings.where(listing_type: params[:listing_type]) if params[:listing_type].present?

    if params[:q].present?
      listings = listings.search_by_title_and_description(params[:q])
    end

    listings = listings.page(params[:page]).per([ params[:per_page].to_i, 100 ].clamp(1, 100))

    render json: {
      data:  listings.map { |l| serialize_listing(l) },
      meta:  pagination_meta(listings)
    }
  end

  # GET /api/v1/listings/:id
  def show
    require_scope! "read:listings"
    render json: { data: serialize_listing(@listing, detailed: true) }
  end

  # POST /api/v1/listings
  def create
    require_scope! "write:listings"

    listing = current_account.listings.new(listing_params)
    listing.account = current_account

    if listing.save
      render json: { data: serialize_listing(listing, detailed: true) }, status: :created
    else
      render json: { errors: listing.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/listings/:id
  def update
    require_scope! "write:listings"
    authorize @listing

    if @listing.update(listing_params)
      render json: { data: serialize_listing(@listing, detailed: true) }
    else
      render json: { errors: @listing.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/listings/:id
  def destroy
    require_scope! "write:listings"
    authorize @listing

    @listing.discard
    render json: { message: "Listing archived." }
  end

  private

  def set_listing
    @listing = Listing.kept.find(params[:id])
  end

  def listing_params
    params.require(:listing).permit(
      :title, :description, :price, :currency, :condition, :listing_type,
      :quantity_available, :category_id, :brand_id, :sku, :location,
      :rental_period, :rental_price, printer_model_ids: []
    )
  end

  def serialize_listing(listing, detailed: false)
    base = {
      id:               listing.id,
      title:            listing.title,
      price:            listing.price,
      currency:         listing.currency,
      condition:        listing.condition,
      listing_type:     listing.listing_type,
      status:           listing.status,
      category:         listing.category&.name,
      brand:            listing.brand&.name,
      views_count:      listing.views_count,
      created_at:       listing.created_at,
      updated_at:       listing.updated_at
    }

    if detailed
      base.merge!(
        description:   listing.description,
        sku:           listing.sku,
        location:      listing.location,
        printer_models: listing.printer_models.map { |m| { id: m.id, name: m.name } },
        quantity_available: listing.quantity_available,
      )
    end

    base
  end

  def pagination_meta(collection)
    {
      current_page:  collection.current_page,
      total_pages:   collection.total_pages,
      total_count:   collection.total_count,
      per_page:      collection.limit_value
    }
  end
end
