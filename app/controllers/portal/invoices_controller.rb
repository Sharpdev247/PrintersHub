module Portal
  class InvoicesController < Portal::BaseController
    before_action :find_invoice, only: [ :show ]

    def index
      @invoices = Invoice.order_type
                         .for_account(Current.account)
                         .includes(:order, :buyer_account, :account, :invoice_items)
                         .recent
                         .page(params[:page]).per(20)
    end

    # GET /portal/invoices/:id
    # GET /portal/invoices/:id.html (browser view / print)
    def show
    end

    # POST /portal/orders/:order_id/invoice — generate invoice for an order
    def create
      order = policy_scope(Order).find(params[:order_id])

      unless order.buyer_account_id == Current.account.id ||
             order.seller_account_id == Current.account.id
        redirect_to portal_invoices_path, alert: "Not authorised."
        return
      end

      invoice = InvoiceGenerator.call(order)
      redirect_to portal_invoice_path(invoice)
    end

    private

    def find_invoice
      @invoice = Invoice.order_type.for_account(Current.account).find(params[:id])
    end
  end
end
