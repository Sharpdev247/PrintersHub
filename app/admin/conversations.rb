ActiveAdmin.register Conversation do
  menu priority: 8, label: "Conversations"

  permit_params :subject, :listing_id

  actions :index, :show, :destroy

  filter :listing, as: :select, collection: -> { Listing.order(:title).map { |l| [truncate(l.title, length: 60), l.id] } }
  filter :subject
  filter :created_at
  filter :updated_at

  scope :all, default: true

  index do
    selectable_column
    id_column
    column :subject do |c|
      c.subject.presence || "(no subject)"
    end
    column("Listing") do |c|
      c.listing ? link_to(truncate(c.listing.title, length: 50), admin_listing_path(c.listing)) : "—"
    end
    column("Participants") { |c| c.participants.map(&:email).join(", ") }
    column("Messages") { |c| c.messages.count }
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :subject
      row :listing do |c|
        c.listing ? link_to(c.listing.title, admin_listing_path(c.listing)) : "—"
      end
      row :created_at
      row :updated_at
    end

    panel "Participants (#{conversation.conversation_participants.count})" do
      table_for conversation.conversation_participants.includes(:user) do
        column("User")      { |cp| link_to cp.user.email, admin_user_path(cp.user) }
        column("Role")      { |cp| cp.role.humanize }
        column("Joined At") { |cp| cp.joined_at }
        column("Left At")   { |cp| cp.left_at || "—" }
      end
    end

    panel "Messages (#{conversation.messages.count})" do
      table_for conversation.messages.chronological do
        column("Sender")     { |m| m.user.email }
        column("Body")       { |m| truncate(m.body, length: 100) }
        column("Read At")    { |m| m.read_at || "Unread" }
        column("Sent At")    { |m| m.created_at }
      end
    end
  end

  config.sort_order = "updated_at_desc"
end
