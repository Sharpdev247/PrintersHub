module Portal
  module Buyer
    class OrdersController < Portal::BaseController
      before_action :find_order, only: [ :show, :cancel ]

      def index
        @orders = policy_scope(Order)
                    .for_buyer(Current.account)
                    .includes(:seller_account, order_items: :listing)
                    .recent
                    .page(params[:page]).per(20)
      end

      def show
        authorize @order
      end

      # POST /portal/buyer/orders — create order from a single listing (direct buy)
      def create
        listing = Listing.kept.friendly.find(params[:listing_id])

        @order = Order.new(
          buyer_account:    Current.account,
          seller_account:   listing.account,
          created_by:       current_user,
          currency:         listing.currency,
          subtotal:         listing.price,
          tax_amount:       0,
          shipping_amount:  0,
          discount_amount:  0,
          total:            listing.price
        )

        authorize @order

        Order.transaction do
          @order.save!
          @order.order_items.create!(
            listing:        listing,
            seller_account: listing.account,
            quantity:       1,
            unit_price:     listing.price,
            currency:       listing.currency,
            tax_amount:     0,
            discount_amount: 0,
            total:          listing.price
          )
          @order.transition_to!(:pending_payment, changed_by: current_user, source: "buyer")
        end

        redirect_to portal_buyer_order_path(@order),
                    notice: "Order #{@order.order_number} created. Please complete payment."
      rescue ActiveRecord::RecordInvalid => e
        redirect_to listing_path(listing), alert: e.message
      end

      # PATCH /portal/buyer/orders/:id/cancel
      def cancel
        authorize @order, :cancel?

        if @order.cancellable?
          @order.cancel!(cancelled_by: current_user, reason: params[:reason])
          redirect_to portal_buyer_order_path(@order), notice: "Order cancelled."
        else
          redirect_to portal_buyer_order_path(@order),
                      alert: "This order cannot be cancelled at its current stage."
        end
      end

      private

      def find_order
        @order = policy_scope(Order).for_buyer(Current.account).find(params[:id])
      end
    end
  end
end
