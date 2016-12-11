class ManageIQ::Providers::Hawkular::DatawarehouseManager::EventCatcher::Stream
  include ManageIQ::Providers::Hawkular::Common::EventCatcher::StreamMixin

  def initialize(ems)
    @ems               = ems
    @alerts_client     = ems.alerts_client
    @collecting_events = false
  end

  private

  def log_handle
    $datawarehouse_log
  end

  def hawkular_tag_expression
    "type|node"
  end

  def calculate_start_time
    last_event = @ems.generated_events.last
    # timestamp is converted to our tz, use hawkular reported time.
    last_event ? last_event.full_data[:ctime] : 0
  end
end
