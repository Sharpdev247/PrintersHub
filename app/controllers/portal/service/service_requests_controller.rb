module Portal
  module Service
    class ServiceRequestsController < Portal::BaseController
      before_action :require_service_access
      before_action :find_request, only: [ :show, :edit, :update, :assign, :transition ]

      def index
        base = policy_scope(ServiceRequest).includes(:assigned_to, :printer_model, :customer_account)
        base = base.by_status(params[:status])     if params[:status].present?
        base = base.by_priority(params[:priority]) if params[:priority].present?
        base = base.where(assigned_to: current_user) if params[:mine].present?

        @requests = base.recent.page(params[:page]).per(25)
        @counts   = policy_scope(ServiceRequest).group(:status).count
      end

      def show; end

      def new
        @request = Current.account.service_requests.new(
          priority: "normal",
          currency: "USD",
          reported_at: Time.current
        )
        authorize @request
      end

      def create
        @request = Current.account.service_requests.new(service_request_params)
        authorize @request

        if @request.save
          redirect_to portal_service_service_request_path(@request),
                      notice: "Service request #{@request.request_number} created."
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        authorize @request, :update?
      end

      def update
        authorize @request, :update?

        if @request.update(service_request_params)
          redirect_to portal_service_service_request_path(@request), notice: "Request updated."
        else
          render :edit, status: :unprocessable_entity
        end
      end

      # PATCH /portal/service/service_requests/:id/assign
      def assign
        authorize @request, :update?

        technician = if params[:technician_id].present?
          # Scope to users who are members of this account (safety check)
          User.joins(:memberships)
              .where(memberships: { account: Current.account, discarded_at: nil })
              .find(params[:technician_id])
        end

        @request.update!(assigned_to: technician)
        redirect_to portal_service_service_request_path(@request),
                    notice: technician ? "Assigned to #{technician.email}." : "Unassigned."
      rescue ActiveRecord::RecordNotFound
        redirect_to portal_service_service_request_path(@request), alert: "Technician not found."
      end

      # PATCH /portal/service/service_requests/:id/transition
      def transition
        authorize @request, :update?
        new_status = params[:status].to_s
        unless ServiceRequest::STATUSES.include?(new_status)
          redirect_to portal_service_service_request_path(@request), alert: "Invalid status."
          return
        end
        @request.transition_to!(new_status, changed_by: current_user)
        redirect_to portal_service_service_request_path(@request),
                    notice: "Status updated to #{new_status.humanize}."
      end

      private

      def require_service_access
        unless Current.role.in?(%w[owner admin manager technician])
          redirect_to portal_root_path, alert: "Access denied."
        end
      end

      def find_request
        @request = policy_scope(ServiceRequest).find(params[:id])
        authorize @request
      end

      def service_request_params
        params.require(:service_request).permit(
          :title, :description, :priority, :status,
          :printer_model_id, :serial_number,
          :assigned_to_id, :customer_account_id,
          :estimated_cost, :final_cost, :currency,
          :scheduled_at, :notes, :diagnosis, :resolution,
          :reported_at
        )
      end
    end
  end
end
