module Api
  module Subcollections
    module AlertStatuses
      include Subcollections::AlertStatusStates

      def alert_statuses_query_resource(object)
        alerts = []
        alerts = object.miq_alert_statuses.collect(&:to_json) if object.respond_to?(:miq_alert_statuses)
        alerts
      end
    end
  end
end
