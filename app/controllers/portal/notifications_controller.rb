module Portal
  class NotificationsController < Portal::BaseController
    before_action :find_notification, only: [ :show ]

    def index
      @notifications = current_user.notifications
                                   .recent
                                   .page(params[:page]).per(30)
      @unread_count  = current_user.notifications.unread.count
    end

    # GET /portal/notifications/:id — mark read then redirect to linked resource
    def show
      @notification.mark_read!
      redirect_to resolve_destination(@notification)
    end

    # PATCH /portal/notifications/mark_all_read
    def mark_all_read
      Notification.mark_all_read_for(current_user)
      redirect_to portal_notifications_path, notice: "All notifications marked as read."
    end

    private

    def find_notification
      @notification = current_user.notifications.find(params[:id])
    end

    def resolve_destination(n)
      case n.notification_type
      when "offer_received", "offer_accepted", "offer_rejected",
           "offer_countered", "offer_withdrawn", "offer_expired"
        portal_notifications_path   # TODO: link to offer when Order phase is built
      when "new_message"
        portal_notifications_path   # TODO: link to conversation
      when "listing_published", "listing_approved", "listing_rejected"
        n.notifiable ? portal_seller_listing_path(n.notifiable) : portal_notifications_path
      else
        portal_notifications_path
      end
    rescue ActionController::RoutingError
      portal_notifications_path
    end
  end
end
