module ManageIQ::Providers::Hawkular::Common::EventCatcher::StreamMixin
  extend ActiveSupport::Concern

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

  def fetch
    @start_time ||= calculate_start_time
    log_handle.debug "Fetching Events since [#{@start_time}]"
    new_events = @alerts_client.list_alerts("startTime" => @start_time, "thin" => true, "tags" => hawkular_tag_expression)
    @start_time = new_events.max_by(&:ctime).ctime + 1 unless new_events.empty?
    new_events
  rescue => err
    log_handle.error "Error capturing events #{err}"
    []
  end
end
