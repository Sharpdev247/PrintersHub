ActiveAdmin.register Cart do
  permit_params :account_id, :created_by_id, :status, :currency, :expires_at, :notes

  scope :all
  scope("Active")       { |s| s.status_active }
  scope("Abandoned")    { |s| s.status_abandoned }
  scope("Checked Out")  { |s| s.status_checked_out }

  filter :account, as: :select, collection: -> { Account.order(:name).pluck(:name, :id) }
  filter :status, as: :select, collection: Cart.statuses.keys.map { |s| [ s.humanize, s ] }
  filter :currency
  filter :created_at

  index do
    selectable_column
    id_column
    column :account do |c|
      link_to c.account.name, admin_account_path(c.account) if c.account
    end
    column :created_by do |c|
      c.created_by&.email
    end
    column :status do |c|
      status_tag c.status.humanize
    end
    column :currency
    column(:items) { |c| c.cart_items.count }
    column :expires_at
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row(:account) { |c| link_to c.account&.name, admin_account_path(c.account) if c.account }
      row(:created_by) { |c| c.created_by&.email }
      row(:status) { |c| status_tag c.status.humanize }
      row :currency
      row :expires_at
      row :notes
      row :discarded_at
      row :created_at
    end

    panel "Cart Items" do
      table_for cart.cart_items do
        column :listing do |ci|
          link_to ci.listing.title, admin_listing_path(ci.listing) if ci.listing
        end
        column :quantity
        column :unit_price do |ci|
          number_to_currency(ci.unit_price, unit: ci.currency + " ")
        end
        column :currency
        column :added_by do |ci|
          ci.added_by&.email
        end
        column :created_at
      end
    end
  end

  form do |f|
    f.inputs "Cart Details" do
      f.input :account,    as: :select, collection: Account.order(:name).map { |a| [ a.name, a.id ] }
      f.input :created_by, as: :select, collection: User.order(:email).map { |u| [ u.email, u.id ] }
      f.input :status,     as: :select, collection: Cart.statuses.keys.map { |s| [ s.humanize, s ] }
      f.input :currency
      f.input :expires_at, as: :datetime_picker
      f.input :notes
    end
    f.actions
  end
end
