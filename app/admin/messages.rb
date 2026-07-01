ActiveAdmin.register Message do
  menu priority: 9, label: "Messages"

  permit_params :conversation_id, :user_id, :body

  actions :index, :show, :destroy

  filter :conversation_id, label: "Conversation ID"
  filter :user,    as: :select, collection: -> { User.order(:email).map { |u| [u.email, u.id] } }
  filter :read_at, label: "Read At"
  filter :deleted_at
  filter :created_at

  scope :all,               default: true
  scope("Unread")           { |s| s.unread }
  scope("Visible")          { |s| s.visible }
  scope("Soft-Deleted")     { |s| s.where.not(deleted_at: nil) }

  index do
    selectable_column
    id_column
    column("Conversation") { |m| link_to "##{m.conversation_id}", admin_conversation_path(m.conversation) }
    column("Sender")       { |m| m.user.email }
    column("Body")         { |m| truncate(m.body, length: 80) }
    column("Read") do |m|
      status_tag m.read? ? "Yes" : "No", class: m.read? ? "yes" : "no"
    end
    column("Deleted") do |m|
      status_tag m.deleted? ? "Yes" : "No", class: m.deleted? ? "no" : "yes"
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :conversation do |m|
        link_to "##{m.conversation_id}", admin_conversation_path(m.conversation)
      end
      row("Sender") { |m| m.user.email }
      row :body
      row :read_at
      row :edited_at
      row :deleted_at
      row :created_at
      row :updated_at
    end
  end

  config.sort_order = "created_at_desc"
end
