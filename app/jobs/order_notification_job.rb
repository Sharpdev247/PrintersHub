# Delivers notifications to both buyer and seller when an order changes status.
# Enqueue from order controllers:
#   OrderNotificationJob.perform_later(order, changed_by_id: current_user.id)
class OrderNotificationJob < ApplicationJob
  queue_as :default

  def perform(order, changed_by_id: nil)
    return unless order.is_a?(Order)

    status       = order.status.humanize
    order_ref    = order.order_number
    changed_by   = changed_by_id ? User.find_by(id: changed_by_id) : nil

    # Notify buyer
    buyer_user = order.buyer_account.users
                      .joins(:memberships)
                      .where(memberships: { role: Membership.roles[:owner], discarded_at: nil })
                      .first

    if buyer_user
      Notification.deliver(
        user:       buyer_user,
        type:       order_notification_type(order),
        title:      "Order #{order_ref}: #{status}",
        body:       buyer_message(order, status),
        data:       { order_id: order.id, order_number: order_ref, status: order.status },
        notifiable: order
      )
    end

    # Notify seller (if status was changed by buyer, or it's a new order)
    seller_user = order.seller_account.users
                       .joins(:memberships)
                       .where(memberships: { role: Membership.roles[:owner], discarded_at: nil })
                       .first

    if seller_user && seller_user != changed_by
      Notification.deliver(
        user:       seller_user,
        type:       order_notification_type(order),
        title:      "Order #{order_ref}: #{status}",
        body:       seller_message(order, status),
        data:       { order_id: order.id, order_number: order_ref, status: order.status },
        notifiable: order
      )
    end
  end

  private

  def order_notification_type(order)
    case order.status
    when "cancelled" then "system"
    else "system"
    end
  end

  def buyer_message(order, status)
    case order.status
    when "processing"        then "Your order is being processed."
    when "shipped"           then "Your order has been shipped."
    when "delivered"         then "Your order has been delivered."
    when "completed"         then "Your order is complete. Thank you!"
    when "cancelled"         then "Your order has been cancelled."
    when "payment_confirmed" then "Your payment has been confirmed."
    else "Your order #{order.order_number} is now #{status}."
    end
  end

  def seller_message(order, status)
    case order.status
    when "pending_payment"   then "New order #{order.order_number} received — awaiting payment."
    when "payment_confirmed" then "Payment confirmed for order #{order.order_number}."
    when "cancelled"         then "Order #{order.order_number} was cancelled."
    else "Order #{order.order_number} status: #{status}."
    end
  end
end
