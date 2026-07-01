ActiveAdmin.register Notification do
  menu priority: 12, label: "Notifications"

  permit_params :user_id, :title, :body, :notification_type, :read_at, :data

  actions :index, :show, :destroy

  filter :user,              as: :select, collection: -> { User.order(:email).map { |u| [u.email, u.id] } }
  filter :notification_type, as: :select, collection: Notification::TYPES.map { |t| [t.humanize, t] }
  filter :read_at,           label: "Read At"
  filter :created_at

  scope :all,      default: true
  scope("Unread")  { |s| s.unread }
  scope("Read")    { |s| s.read }

  index do
    selectable_column
    id_column
    column :user do |n| n.user.email end
    column :notification_type do |n| n.notification_type.humanize end
    column :title
    column("Read") do |n|
      status_tag n.read? ? "Yes" : "No", class: n.read? ? "yes" : "no"
    end
    column :read_at
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :user do |n| n.user.email end
      row :notification_type do |n| n.notification_type.humanize end
      row :title
      row :body
      row("Read") { |n| status_tag n.read? ? "Yes" : "No", class: n.read? ? "yes" : "no" }
      row :read_at
      row :notifiable_type
      row :notifiable_id
      row :created_at
      row :updated_at
    end

    panel "Data Payload" do
      pre do
        JSON.pretty_generate(notification.data)
      end
    end
  end

  member_action :mark_read, method: :put do
    resource.mark_read!
    redirect_to admin_notification_path(resource), notice: "Notification marked as read."
  end

  action_item :mark_read, only: :show, if: -> { !resource.read? } do
    link_to "Mark Read", mark_read_admin_notification_path(resource), method: :put
  end

  config.sort_order = "created_at_desc"
end
