class Portal::DashboardController < Portal::BaseController
  def show
    # Role-based redirect to the right dashboard.
    membership = Current.user.memberships.kept.find_by(account: Current.account)
    role       = membership&.role&.to_sym

    case role
    when :owner, :admin, :manager, :sales
      redirect_to portal_seller_path
    when :technician, :warehouse_staff
      redirect_to portal_service_path
    when :accountant
      redirect_to portal_seller_path
    else
      redirect_to root_path
    end
  end
end
