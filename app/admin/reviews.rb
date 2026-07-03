ActiveAdmin.register Review do
  menu priority: 11, label: "Reviews"

  permit_params :listing_id, :reviewer_id, :reviewee_id, :rating, :body, :status

  filter :listing, as: :select, collection: -> { Listing.order(:title).map { |l| [ truncate(l.title, length: 60), l.id ] } }
  filter :status,  as: :select, collection: Review.statuses.keys.map { |s| [ s.humanize, s ] }
  filter :rating,  as: :select, collection: (1..5).map { |r| [ "#{r} star#{'s' if r > 1}", r ] }
  filter :created_at

  scope :all,          default: true
  scope("Pending")     { |s| s.pending }
  scope("Published")   { |s| s.published }
  scope("Rejected")    { |s| s.where(status: Review.statuses[:rejected]) }

  index do
    selectable_column
    id_column
    column("Listing") do |r|
      link_to truncate(r.listing.title, length: 50), admin_listing_path(r.listing)
    end
    column("Reviewer") { |r| r.reviewer.email }
    column("Reviewee") { |r| r.reviewee.email }
    column :rating do |r|
      "★" * r.rating + "☆" * (5 - r.rating)
    end
    column :status do |r|
      classes = { "published" => "yes", "pending" => "orange", "rejected" => "no" }
      status_tag r.status.humanize, class: classes[r.status] || "no"
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :listing do |r| link_to r.listing.title, admin_listing_path(r.listing) end
      row("Reviewer") { |r| r.reviewer.email }
      row("Reviewee") { |r| r.reviewee.email }
      row :rating do |r| "★" * r.rating + "☆" * (5 - r.rating) end
      row :body
      row :status do |r|
        classes = { "published" => "yes", "pending" => "orange", "rejected" => "no" }
        status_tag r.status.humanize, class: classes[r.status] || "no"
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Review Details" do
      f.input :listing,  as: :select, collection: Listing.order(:title).map { |l| [ truncate(l.title, length: 60), l.id ] }
      f.input :reviewer, as: :select, collection: User.order(:email).map { |u| [ u.email, u.id ] }
      f.input :reviewee, as: :select, collection: User.order(:email).map { |u| [ u.email, u.id ] }
      f.input :rating,   as: :select, collection: (1..5).map { |r| [ "#{r} star#{'s' if r > 1}", r ] }
      f.input :body
      f.input :status,   as: :select, collection: Review.statuses.keys.map { |s| [ s.humanize, s ] }
    end
    f.actions
  end

  member_action :approve, method: :put do
    resource.approve!
    redirect_to admin_review_path(resource), notice: "Review published."
  end

  member_action :reject_review, method: :put do
    resource.reject!
    redirect_to admin_review_path(resource), notice: "Review rejected."
  end

  action_item :approve, only: :show, if: -> { resource.status_pending? } do
    link_to "Approve", approve_admin_review_path(resource), method: :put,
            data: { confirm: "Publish this review?" }
  end

  action_item :reject_review, only: :show, if: -> { resource.status_pending? } do
    link_to "Reject", reject_review_admin_review_path(resource), method: :put,
            data: { confirm: "Reject this review?" }
  end

  config.sort_order = "created_at_desc"
end
