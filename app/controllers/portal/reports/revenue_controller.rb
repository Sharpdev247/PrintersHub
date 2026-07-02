module Portal
  module Reports
    class RevenueController < BaseController
      def show
        @report = RevenueReport.new(
          account:  Current.account,
          from:     @from,
          to:       @to,
          group_by: group_by
        ).call
      end
    end
  end
end
