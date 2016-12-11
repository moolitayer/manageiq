class ManageIQ::Providers::Hawkular::DatawarehouseManager::EventCatcher::Stream
  def initialize(ems)
    @ems               = ems
    @alerts_client     = ems.alerts_client
    @collecting_events = false
  end

  def start
    @collecting_events = true
  end

  def stop
    @collecting_events = false
  end

  def each_batch
    while @collecting_events
      yield fetch
    end
  end

  private

  def fetch
    @start_time ||= calculate_start_time
    $dw_log.debug "Catching Events since [#{@start_time}]"
    new_events = @alerts_client.list_events("startTime" => @start_time, "thin" => true, "tags" => "clusterid")
    @start_time = new_events.max_by(&:ctime).ctime + 1 unless new_events.empty? # add 1 ms to avoid dups with GTE filter

    new_events
  rescue => err
    $dw_log.error "Error capturing events #{err}"
    []
  end

  def calculate_start_time
    last_event = @ems.carried_events.last
    # timestamp is converted to our tz, use hawkular reported time.
    last_event ? last_event.full_data[:ctime] : 0
  end
end
