ActiveAdmin.register Offer do
  menu parent: "Commerce", priority: 3, label: "Offers"

  permit_params :listing_id, :buyer_id, :seller_id, :proposed_by_id,
                :amount, :currency, :status, :message, :expires_at

  filter :listing, as: :select, collection: -> { Listing.order(:title).map { |l| [ truncate(l.title, length: 60), l.id ] } }
  filter :status,  as: :select, collection: Offer.statuses.keys.map { |s| [ s.humanize, s ] }
  filter :amount
  filter :currency
  filter :expires_at
  filter :created_at

  scope :all,        default: true
  scope("Pending")   { |s| s.pending }
  scope("Active")    { |s| s.active }
  scope("Accepted")  { |s| s.where(status: Offer.statuses[:accepted]) }
  scope("Rejected")  { |s| s.where(status: Offer.statuses[:rejected]) }
  scope("Countered") { |s| s.where(status: Offer.statuses[:countered]) }
  scope("Withdrawn") { |s| s.where(status: Offer.statuses[:withdrawn]) }
  scope("Expired")   { |s| s.where(status: Offer.statuses[:expired]) }
  scope("Root Offers") { |s| s.root }

  index do
    selectable_column
    id_column
    column("Listing") do |o|
      link_to truncate(o.listing.title, length: 50), admin_listing_path(o.listing)
    end
    column("Buyer")  { |o| o.buyer.email }
    column("Seller") { |o| o.seller.email }
    column("Amount") { |o| number_to_currency(o.amount, unit: o.currency, precision: 2) }
    column :status do |o|
      classes = {
        "pending" => "orange", "accepted" => "yes", "rejected" => "no",
        "countered" => "orange", "withdrawn" => "no", "expired" => "no"
      }
      status_tag o.status.humanize, class: classes[o.status] || "no"
    end
    column("Proposed By") { |o| o.proposed_by.email }
    column :expires_at
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :listing do |o|
        link_to o.listing.title, admin_listing_path(o.listing)
      end
      row :buyer  do |o| o.buyer.email end
      row :seller do |o| o.seller.email end
      row("Proposed By") { |o| o.proposed_by.email }
      row :amount do |o| number_to_currency(o.amount, unit: o.currency, precision: 2) end
      row :currency
      row :status do |o|
        classes = { "accepted" => "yes", "rejected" => "no", "pending" => "orange" }
        status_tag o.status.humanize, class: classes[o.status] || "no"
      end
      row :message
      row :expires_at
      row :parent_offer do |o|
        o.parent_offer ? link_to("Offer ##{o.parent_offer_id}", admin_offer_path(o.parent_offer)) : "—"
      end
      row :created_at
      row :updated_at
    end

    if offer.counter_offers.any?
      panel "Counter Offers (#{offer.counter_offers.count})" do
        table_for offer.counter_offers do
          column :id do |co| link_to "##{co.id}", admin_offer_path(co) end
          column("Amount") { |co| number_to_currency(co.amount, unit: co.currency, precision: 2) }
          column("Proposed By") { |co| co.proposed_by.email }
          column :status do |co| co.status.humanize end
          column :created_at
        end
      end
    end
  end

  # ── Member actions ──────────────────────────────────────────────────────────
  member_action :accept, method: :put do
    resource.accept!
    redirect_to admin_offer_path(resource), notice: "Offer accepted."
  rescue => e
    redirect_to admin_offer_path(resource), alert: "Could not accept: #{e.message}"
  end

  member_action :reject, method: :put do
    resource.reject!
    redirect_to admin_offer_path(resource), notice: "Offer rejected."
  end

  member_action :expire, method: :put do
    resource.update!(status: :expired)
    redirect_to admin_offer_path(resource), notice: "Offer marked as expired."
  end

  action_item :accept, only: :show, if: -> { resource.status_pending? } do
    link_to "Accept", accept_admin_offer_path(resource), method: :put,
            data: { confirm: "Accept this offer?" }
  end

  action_item :reject, only: :show, if: -> { resource.status_pending? } do
    link_to "Reject", reject_admin_offer_path(resource), method: :put,
            data: { confirm: "Reject this offer?" }
  end

  action_item :expire, only: :show, if: -> { resource.status_pending? } do
    link_to "Mark Expired", expire_admin_offer_path(resource), method: :put,
            data: { confirm: "Mark this offer as expired?" }
  end

  config.sort_order = "created_at_desc"
end
