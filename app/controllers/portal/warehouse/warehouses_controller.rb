module Portal
  module Warehouse
    class WarehousesController < Portal::BaseController
      before_action :require_warehouse_access
      before_action :find_warehouse, only: [ :show, :edit, :update ]

      def index
        @warehouses = policy_scope(::Warehouse)
                        .kept
                        .includes(:warehouse_zones, :inventory_items)
                        .order(:name)
      end

      def show
        @inventory_items = @warehouse.inventory_items
                                     .active
                                     .includes(product_variant: :product)
                                     .order("quantity_on_hand - reserved_quantity ASC")
                                     .page(params[:page]).per(30)
        @zones = @warehouse.warehouse_zones.order(:name)
      end

      def new
        @warehouse = Current.account.warehouses.new
        authorize @warehouse
      end

      def create
        @warehouse = Current.account.warehouses.new(warehouse_params)
        authorize @warehouse

        if @warehouse.save
          redirect_to portal_warehouse_warehouse_path(@warehouse),
                      notice: "Warehouse #{@warehouse.name} created."
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        authorize @warehouse, :update?
      end

      def update
        authorize @warehouse, :update?

        if @warehouse.update(warehouse_params)
          redirect_to portal_warehouse_warehouse_path(@warehouse),
                      notice: "Warehouse updated."
        else
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def require_warehouse_access
        unless Current.role.in?(%w[owner admin manager warehouse_staff])
          redirect_to portal_root_path, alert: "Access denied."
        end
      end

      def find_warehouse
        @warehouse = policy_scope(::Warehouse).kept.find(params[:id])
      end

      def warehouse_params
        params.require(:warehouse).permit(
          :name, :code, :address_line1, :address_line2,
          :city, :country_code, :contact_name, :email, :active
        )
      end
    end
  end
end
