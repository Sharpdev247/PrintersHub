class Api::V1::OrdersController < Api::V1::BaseController
  before_action :set_order, only: [ :show, :update_status, :cancel ]

  # GET /api/v1/orders
  def index
    require_scope! "read:orders"

    orders = Order.for_account(current_account)
                  .includes(:order_items, :buyer_account, :seller_account)
                  .order(created_at: :desc)

    orders = orders.where(status: params[:status]) if params[:status].present?
    orders = orders.page(params[:page]).per(50)

    render json: {
      data: orders.map { |o| serialize_order(o) },
      meta: pagination_meta(orders)
    }
  end

  # GET /api/v1/orders/:id
  def show
    require_scope! "read:orders"
    render json: { data: serialize_order(@order, detailed: true) }
  end

  # PATCH /api/v1/orders/:id/status
  def update_status
    require_scope! "write:orders"
    unless @order.seller_account == current_account
      return render json: { error: "Forbidden" }, status: :forbidden
    end

    new_status = params.require(:status)
    @order.transition_to!(new_status)
    render json: { data: serialize_order(@order) }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # PATCH /api/v1/orders/:id/cancel
  def cancel
    require_scope! "write:orders"
    unless @order.cancellable?
      return render json: { error: "Order cannot be cancelled in its current state." }, status: :unprocessable_entity
    end

    @order.transition_to!("cancelled")
    render json: { data: serialize_order(@order) }
  end

  private

  def set_order
    @order = Order.for_account(current_account).find(params[:id])
  end

  def serialize_order(order, detailed: false)
    base = {
      id:             order.id,
      order_number:   order.order_number,
      status:         order.status,
      total_amount:   order.total_amount,
      currency:       order.currency,
      buyer_account:  order.buyer_account&.name,
      seller_account: order.seller_account&.name,
      created_at:     order.created_at
    }

    if detailed
      base[:items] = order.order_items.map do |item|
        snap = item.listing_snapshot || {}
        {
          id:       item.id,
          title:    snap["title"] || item.listing&.title,
          quantity: item.quantity,
          price:    item.unit_price,
          subtotal: item.subtotal
        }
      end
    end

    base
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      total_pages:  collection.total_pages,
      total_count:  collection.total_count
    }
  end
end
