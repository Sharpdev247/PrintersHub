ActiveAdmin.register ApiToken do
  menu label: "API Tokens", parent: "Platform", priority: 2

  actions :index, :show, :destroy

  filter :account, as: :select, collection: -> { Account.order(:name).pluck(:name, :id) }
  filter :user,    as: :select, collection: -> { User.order(:email).pluck(:email, :id) }
  filter :token_type, as: :select, collection: ApiToken::TOKEN_TYPES
  filter :created_at
  filter :last_used_at
  filter :revoked_at

  scope :all
  scope("Active")  { |s| s.active }
  scope("Revoked") { |s| s.revoked }
  scope("Expired") { |s| s.expired }

  index do
    selectable_column
    id_column
    column :account
    column :user do |t|
      t.user&.email
    end
    column :name
    column :prefix
    column :token_type
    column(:scopes) { |t| t.scopes.join(", ") }
    column(:status) do |t|
      if t.revoked?
        status_tag "Revoked", class: "red"
      elsif t.expired?
        status_tag "Expired", class: "orange"
      else
        status_tag "Active",  class: "green"
      end
    end
    column :last_used_at
    column :expires_at
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :account
      row(:user)   { |t| t.user&.email }
      row :name
      row(:prefix) { |t| t.display_token }
      row :token_type
      row(:scopes) { |t| t.scopes.join(", ") }
      row(:status) do |t|
        if t.revoked?
          status_tag "Revoked", class: "red"
        elsif t.expired?
          status_tag "Expired", class: "orange"
        else
          status_tag "Active",  class: "green"
        end
      end
      row :last_used_at
      row :expires_at
      row :revoked_at
      row :created_at
    end
  end

  member_action :revoke, method: :post do
    resource.revoke!
    redirect_to admin_api_token_path(resource), notice: "Token revoked."
  end

  action_item :revoke, only: :show, if: -> { resource.active? } do
    link_to "Revoke Token", revoke_admin_api_token_path(resource),
            method: :post, data: { confirm: "Revoke this token? This cannot be undone." }
  end
end
