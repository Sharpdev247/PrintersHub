module Portal
  class ActivityLogsController < Portal::BaseController
    before_action :require_admin

    AUDITABLE_TYPES = %w[
      Listing Order Invoice Contact ServiceRequest
      Membership InventoryItem Warehouse Account
      PurchaseOrder Supplier
    ].freeze

    def index
      audits = Audited::Audit
        .where(associated_type: "Account", associated_id: Current.account.id)
        .or(
          Audited::Audit.where(
            auditable_type: "Account",
            auditable_id: Current.account.id
          )
        )

      # Also pull direct audits on objects belonging to this account via auditable
      # For models using `audited associated_with: :account`, associated_type/id is set.
      # For plain `audited`, we rely on the user filter below.
      # Merge: union-like approach via a combined scope
      member_ids = Current.account.memberships.pluck(:user_id)

      audits = Audited::Audit
        .where(
          "(associated_type = 'Account' AND associated_id = ?) OR " \
          "(auditable_type = 'Account' AND auditable_id = ?) OR " \
          "user_id IN (?)",
          Current.account.id, Current.account.id, member_ids
        )

      # Filters
      if params[:auditable_type].present? && params[:auditable_type].in?(AUDITABLE_TYPES)
        audits = audits.where(auditable_type: params[:auditable_type])
      end

      if params[:action_type].present? && params[:action_type].in?(%w[create update destroy])
        audits = audits.where(action: params[:action_type])
      end

      if params[:user_id].present?
        audits = audits.where(user_id: params[:user_id])
      end

      if params[:q].present?
        # Search across username stored in audit comment or user lookup
        user_ids = User.where("LOWER(email) LIKE ?", "%#{params[:q].downcase}%")
                       .joins(:memberships)
                       .where(memberships: { account: Current.account })
                       .pluck(:id)
        audits = audits.where(user_id: user_ids) if user_ids.any?
      end

      @audits = audits.order(created_at: :desc).page(params[:page]).per(40)
      @members = User.joins(:memberships)
                     .where(memberships: { account: Current.account, discarded_at: nil })
                     .order(:email)
    end

    private

    def require_admin
      unless Current.role.in?(%w[owner admin])
        redirect_to portal_root_path, alert: "Access denied."
      end
    end
  end
end
