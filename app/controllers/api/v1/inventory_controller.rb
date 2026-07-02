class Api::V1::InventoryController < Api::V1::BaseController
  before_action :set_item, only: [:show, :adjust]

  # GET /api/v1/inventory
  def index
    require_scope! "read:inventory"

    items = InventoryItem.joins(:warehouse)
                         .where(warehouses: { account_id: current_account.id })
                         .active
                         .includes(:warehouse, :listing)
                         .order(:sku)

    items = items.where(sku: params[:sku])                       if params[:sku].present?
    items = items.where(warehouse_id: params[:warehouse_id])     if params[:warehouse_id].present?
    items = items.out_of_stock                                   if params[:out_of_stock] == "true"
    items = items.low_stock                                      if params[:low_stock] == "true"

    items = items.page(params[:page]).per(100)

    render json: {
      data: items.map { |i| serialize_item(i) },
      meta: pagination_meta(items)
    }
  end

  # GET /api/v1/inventory/:id
  def show
    require_scope! "read:inventory"
    render json: { data: serialize_item(@item, detailed: true) }
  end

  # POST /api/v1/inventory/:id/adjust
  def adjust
    require_scope! "write:inventory"

    quantity = params.require(:quantity).to_i
    note     = params[:note].presence || "API adjustment"

    old_qty = @item.quantity_on_hand
    new_qty = old_qty + quantity

    if new_qty < 0
      return render json: { error: "Adjustment would result in negative stock." }, status: :unprocessable_entity
    end

    @item.update!(quantity_on_hand: new_qty)
    @item.inventory_transactions.create!(
      account:         current_account,
      transaction_type: :adjustment,
      direction:       quantity >= 0 ? :in : :out,
      quantity_before: old_qty,
      quantity_change: quantity,
      quantity_after:  new_qty,
      performed_at:    Time.current,
      performed_by:    current_user,
      source:          "api",
      notes:           note
    )

    render json: { data: serialize_item(@item) }
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def set_item
    @item = InventoryItem.joins(:warehouse)
                         .where(warehouses: { account_id: current_account.id })
                         .find(params[:id])
  end

  def serialize_item(item, detailed: false)
    base = {
      id:                item.id,
      sku:               item.sku,
      quantity_on_hand:  item.quantity_on_hand,
      reserved_quantity: item.reserved_quantity,
      available:         item.quantity_on_hand - item.reserved_quantity,
      reorder_point:     item.reorder_point,
      low_stock:         item.low_stock?,
      warehouse:         item.warehouse&.name,
      listing_title:     item.listing&.title,
      updated_at:        item.updated_at,
    }

    if detailed
      base[:recent_transactions] = item.inventory_transactions
        .order(performed_at: :desc)
        .limit(10)
        .map do |t|
          {
            type:    t.transaction_type,
            change:  t.quantity_change,
            after:   t.quantity_after,
            at:      t.performed_at,
            source:  t.source,
            notes:   t.notes,
          }
        end
    end

    base
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      total_pages:  collection.total_pages,
      total_count:  collection.total_count,
    }
  end
end
