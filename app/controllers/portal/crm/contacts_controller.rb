module Portal
  module Crm
    class ContactsController < Portal::BaseController
      before_action :require_sales_access
      before_action :find_contact, only: [:show, :edit, :update, :destroy]

      def index
        base = policy_scope(Contact).includes(:owner, :contact_notes)

        base = base.where(contact_type: params[:type])     if params[:type].present?
        base = base.where(status: params[:status])         if params[:status].present?
        base = base.where(owner: current_user)             if params[:mine].present?

        if params[:q].present?
          q = "%#{params[:q].downcase}%"
          base = base.where(
            "LOWER(first_name) LIKE :q OR LOWER(last_name) LIKE :q OR
             LOWER(email) LIKE :q OR LOWER(company_name) LIKE :q", q: q
          )
        end

        @contacts = base.recent.page(params[:page]).per(30)
        @counts   = policy_scope(Contact).group(:contact_type).count
      end

      def show
        @notes = @contact.contact_notes.recent.includes(:author)
        @new_note = @contact.contact_notes.new(note_type: "note")
      end

      def new
        @contact = Current.account.contacts.new(contact_type: "lead", status: "active")
        authorize @contact
      end

      def create
        @contact = Current.account.contacts.new(contact_params)
        @contact.owner ||= current_user
        authorize @contact

        if @contact.save
          redirect_to portal_crm_contact_path(@contact),
                      notice: "#{@contact.full_name} added."
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        authorize @contact, :update?
      end

      def update
        authorize @contact, :update?

        if @contact.update(contact_params)
          redirect_to portal_crm_contact_path(@contact), notice: "Contact updated."
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @contact

        @contact.discard
        redirect_to portal_crm_contacts_path, notice: "#{@contact.full_name} archived."
      end

      private

      def require_sales_access
        unless Current.role.in?(%w[owner admin manager sales])
          redirect_to portal_root_path, alert: "Access denied."
        end
      end

      def find_contact
        @contact = policy_scope(Contact).find(params[:id])
        authorize @contact
      end

      def contact_params
        params.require(:contact).permit(
          :first_name, :last_name, :email, :phone,
          :company_name, :contact_type, :status, :source,
          :owner_id, :notes
        )
      end
    end
  end
end
