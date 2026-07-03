module Portal
  module Seller
    class OrdersController < Portal::BaseController
      before_action :require_sales_or_above
      before_action :find_order, only: [ :show, :update_status, :cancel ]

      def index
        @status_filter = params[:status].presence
        @orders = policy_scope(Order)
                    .for_seller(Current.account)
                    .then { |s| @status_filter ? s.where(status: Order.statuses[@status_filter]) : s }
                    .includes(:buyer_account, order_items: :listing)
                    .recent
                    .page(params[:page]).per(20)

        @counts = Order.for_seller(Current.account).group(:status).count
      end

      def show
        authorize @order
        @history = @order.order_status_histories.order(created_at: :asc)
      end

      # PATCH /portal/seller/orders/:id/update_status
      def update_status
        authorize @order, :update?

        new_status = params[:status].to_s
        unless Order.statuses.key?(new_status)
          redirect_to portal_seller_order_path(@order), alert: "Invalid status."
          return
        end

        @order.transition_to!(new_status, changed_by: current_user,
                               note: params[:note], source: "seller")
        OrderNotificationJob.perform_later(@order, changed_by_id: current_user.id)
        redirect_to portal_seller_order_path(@order),
                    notice: "Order moved to #{new_status.humanize}."
      rescue ActiveRecord::RecordInvalid => e
        redirect_to portal_seller_order_path(@order), alert: e.message
      end

      # PATCH /portal/seller/orders/:id/cancel
      def cancel
        authorize @order, :cancel?

        if @order.cancellable?
          @order.cancel!(cancelled_by: current_user, reason: params[:reason])
          OrderNotificationJob.perform_later(@order, changed_by_id: current_user.id)
          redirect_to portal_seller_order_path(@order), notice: "Order cancelled."
        else
          redirect_to portal_seller_order_path(@order),
                      alert: "This order cannot be cancelled at its current stage."
        end
      end

      private

      def require_sales_or_above
        unless Current.role.in?(%w[owner admin manager sales])
          redirect_to portal_seller_path, alert: "Access denied."
        end
      end

      def find_order
        @order = policy_scope(Order).for_seller(Current.account).find(params[:id])
      end
    end
  end
end
