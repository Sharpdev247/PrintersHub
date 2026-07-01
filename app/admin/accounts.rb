ActiveAdmin.register Account do
  menu priority: 3, label: "Accounts"

  permit_params :name, :email, :phone, :website, :account_type, :status, :verified

  filter :account_type, as: :select, collection: Account.account_types.keys
  filter :status, as: :select, collection: Account.statuses.keys
  filter :verified
  filter :discarded_at_not_null, as: :boolean, label: "Soft Deleted"

  scope :all, default: true
  scope("Active")       { |s| s.kept.status_active }
  scope("Suspended")    { |s| s.status_suspended }
  scope("Soft Deleted") { |s| s.where.not(discarded_at: nil) }

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :account_type
    column :status
    column("Verified") { |a| status_tag a.verified? ? "Yes" : "No", class: a.verified? ? "yes" : "no" }
    column("Soft Deleted") { |a| a.discarded_at.present? ? "(soft deleted) #{a.discarded_at.strftime('%Y-%m-%d')}" : "" }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :slug
      row :email
      row :phone
      row :website
      row :account_type
      row :status
      row :verified
      row :verified_at
      row :provider_customer_id
      row :settings
      row :discarded_at
      row :created_at
      row :updated_at
    end

    panel "Memberships (#{account.memberships.count})" do
      table_for account.memberships.includes(:user).order(created_at: :desc) do
        column("User Email") { |m| m.user ? link_to(m.user.email, admin_user_path(m.user)) : "-" }
        column :role
        column :discarded_at
      end
    end
  end

  form do |f|
    f.inputs "Account Details" do
      f.input :name
      f.input :email
      f.input :phone
      f.input :website
      f.input :account_type, as: :select, collection: Account.account_types.keys
      f.input :status, as: :select, collection: Account.statuses.keys
      f.input :verified, as: :boolean
    end
    f.actions
  end

  action_item :verify, only: :show do
    link_to "Verify Account", verify_admin_account_path(account), method: :post unless account.verified?
  end

  member_action :verify, method: :post do
    resource.verify!
    redirect_to admin_account_path(resource), notice: "Account has been verified."
  end

  config.sort_order = "created_at_desc"
end
