module Portal
  module Seller
    class ListingsController < Portal::BaseController
      after_action :verify_authorized
      after_action :verify_policy_scoped, only: :index

      def index
        @listings = policy_scope(current_account_listings)
                      .includes(:category, :brand)
                      .order(created_at: :desc)
                      .page(params[:page]).per(25)
      end

      def show
        @listing = find_listing
        authorize @listing
      end

      def new
        @listing = current_account_listings.build
        authorize @listing
      end

      def create
        @listing = current_account_listings.build(listing_params)
        @listing.user = current_user
        authorize @listing

        begin
          SubscriptionEnforcer.new(Current.account).enforce!(:max_listings)
        rescue SubscriptionEnforcer::LimitError => e
          redirect_to portal_subscription_plans_path,
            alert: e.message
          return
        end

        if @listing.save
          redirect_to portal_seller_listing_path(@listing),
                      notice: "Listing created successfully."
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @listing = find_listing
        authorize @listing
      end

      def update
        @listing = find_listing
        authorize @listing

        if @listing.update(listing_params)
          redirect_to portal_seller_listing_path(@listing),
                      notice: "Listing updated."
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @listing = find_listing
        authorize @listing
        @listing.destroy!
        redirect_to portal_seller_listings_path, notice: "Listing permanently deleted."
      end

      # PATCH /portal/seller/listings/:id/publish
      def publish
        @listing = find_listing
        authorize @listing, :publish?
        @listing.publish!
        redirect_back_or_to portal_seller_listing_path(@listing),
                             notice: "Listing published."
      end

      # PATCH /portal/seller/listings/:id/unpublish
      def unpublish
        @listing = find_listing
        authorize @listing, :unpublish?
        @listing.update!(status: :draft)
        redirect_back_or_to portal_seller_listing_path(@listing),
                             notice: "Listing moved back to draft."
      end

      # PATCH /portal/seller/listings/:id/pause
      def pause
        @listing = find_listing
        authorize @listing, :pause?
        @listing.pause!
        redirect_back_or_to portal_seller_listing_path(@listing),
                             notice: "Listing paused."
      end

      # PATCH /portal/seller/listings/:id/archive
      def archive
        @listing = find_listing
        authorize @listing, :archive?
        @listing.archive!
        redirect_back_or_to portal_seller_listing_path(@listing),
                             notice: "Listing archived."
      end

      # PATCH /portal/seller/listings/:id/mark_sold
      def mark_sold
        @listing = find_listing
        authorize @listing, :mark_sold?
        @listing.mark_sold!
        redirect_back_or_to portal_seller_listing_path(@listing),
                             notice: "Listing marked as sold."
      end

      # POST /portal/seller/listings/:id/duplicate
      def duplicate
        source = find_listing
        authorize source, :duplicate?

        @listing = source.dup
        @listing.title        = "Copy of #{source.title}"
        @listing.status       = :draft
        @listing.published_at = nil
        @listing.slug         = nil
        @listing.views_count  = 0
        @listing.user         = current_user

        if @listing.save
          redirect_to edit_portal_seller_listing_path(@listing),
                      notice: "Listing duplicated. Review and publish when ready."
        else
          redirect_to portal_seller_listing_path(source),
                      alert: "Could not duplicate listing."
        end
      end

      private

      def current_account_listings
        Current.account.listings
      end

      def find_listing
        current_account_listings.kept.friendly.find(params[:id])
      end

      def listing_params
        params.require(:listing).permit(
          :title, :description, :listing_type, :condition, :status,
          :price, :currency, :quantity, :year, :location_city_id,
          :category_id, :brand_id, :printer_model_id,
          :product_id, :inventory_item_id,
          :featured, :external_url, :sku,
          images: [], documents: []
        )
      end
    end
  end
end
