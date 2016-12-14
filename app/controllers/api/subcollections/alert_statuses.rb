module Api
  module Subcollections
    module AlertStatuses
      include Subcollections::AlertStatusStates

      def alert_statuses_query_resource(object)
        alerts = []
        alerts = object.miq_alert_statuses.collect(&:to_json) if object.respond_to?(:miq_alert_statuses)
        if alerts.length == 2
          alerts[0]['severity'] = 'warning'
          alerts[1]['severity'] = 'warning'
        end
        if alerts.length > 2
          alerts[1]['severity'] = 'warning'
          alerts[2]['severity'] = 'danger'
        end
        alerts
      end
    end
  end
end
