module Portal
  module Reports
    class BaseController < Portal::BaseController
      before_action :require_reports_access
      before_action :set_date_range

      private

      def require_reports_access
        unless Current.role.in?(%w[owner admin manager accountant])
          redirect_to portal_root_path, alert: "Access denied."
        end
      end

      def set_date_range
        @period   = params[:period].presence || "30d"
        @from, @to = case @period
        when "7d"   then [ 7.days.ago,   Time.current ]
        when "30d"  then [ 30.days.ago,  Time.current ]
        when "90d"  then [ 90.days.ago,  Time.current ]
        when "12m"  then [ 12.months.ago, Time.current ]
        when "ytd"  then [ Time.current.beginning_of_year, Time.current ]
        else             [ 30.days.ago,  Time.current ]
        end
      end

      def group_by
        @period == "12m" ? :month : :day
      end

      helper_method :period_label
      def period_label
        { "7d" => "Last 7 days", "30d" => "Last 30 days", "90d" => "Last 90 days",
          "12m" => "Last 12 months", "ytd" => "Year to date" }.fetch(@period, "Last 30 days")
      end
    end
  end
end
