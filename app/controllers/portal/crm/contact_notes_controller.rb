module Portal
  module Crm
    class ContactNotesController < Portal::BaseController
      before_action :require_sales_access
      before_action :find_contact

      def create
        @note = @contact.contact_notes.new(note_params)
        @note.author = current_user

        if @note.save
          redirect_to portal_crm_contact_path(@contact), notice: "Note added."
        else
          redirect_to portal_crm_contact_path(@contact),
                      alert: @note.errors.full_messages.to_sentence
        end
      end

      def destroy
        note = @contact.contact_notes.find(params[:id])
        note.destroy
        redirect_to portal_crm_contact_path(@contact), notice: "Note deleted."
      end

      private

      def require_sales_access
        unless Current.role.in?(%w[owner admin manager sales])
          redirect_to portal_root_path, alert: "Access denied."
        end
      end

      def find_contact
        @contact = policy_scope(Contact).find(params[:contact_id])
      end

      def note_params
        params.require(:contact_note).permit(:body, :note_type, :follow_up_at)
      end
    end
  end
end
