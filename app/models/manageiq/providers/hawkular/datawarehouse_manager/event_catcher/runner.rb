class ManageIQ::Providers::Hawkular::DatawarehouseManager::EventCatcher::Runner <
  ManageIQ::Providers::BaseManager::EventCatcher::Runner

  TAG_TYPE = "type".freeze
  TAG_SEVERITY = "severity".freeze
  TAG_CLUSTER = "clusterid".freeze # collect only alerts with this tag

  # keys are content of the tag 'type'
  TARGETS = {
    :node => {
      :target_class => ContainerNode,
      :target_key   => :name,
      :source_key   => 'nodename'
    }
  }.freeze

  def initialize(cfg = {})
    super
  end

  def reset_event_monitor_handle
    @event_monitor_handle = nil
  end

  def whitelist?(event)
    true
  end

  def stop_event_monitor
    @event_monitor_handle.try(:stop)
  ensure
    reset_event_monitor_handle
  end

  def monitor_events
    event_monitor_handle.start
    event_monitor_handle.each_batch do |events|
      event_monitor_running
      new_events = events.select { |e| whitelist?(e) }
      $dw_log.debug("Discarding events #{events - new_events}") if new_events.length < events.length
      if new_events.any?
        $dw_log.debug "Queueing events #{new_events}"
        @queue.enq new_events
      end
      # invoke the configured sleep before the next event fetch
      sleep_poll_normal
    end
  ensure
    reset_event_monitor_handle
  end

  def process_event(event)
    $dw_log.debug "Processing Event #{event}"
    event_hash = event_to_hash(event, @cfg[:ems_id])

    if blacklist?(event_hash[:event_type])
      $dw_log.debug "Filtering blacklisted event [#{event}]"
    else
      $dw_log.debug "Queuing ems event [#{event_hash}]"
      EmsEvent.add_queue('add', event_hash[:ems_id], event_hash)
    end
  end

  private

  def event_monitor_handle
    @event_monitor_handle ||= ManageIQ::Providers::Hawkular::DatawarehouseManager::EventCatcher::Stream.new(@ems)
  end

  def blacklist?(event_type)
    filtered_events.include?(event_type)
  end

  def event_to_hash(event, current_ems_id = nil)
    change_event(event)
    target = find_target(event.tags)
    {
      :ems_id              => target.try(:ext_management_system).try(:id),
      :source_ems_id       => current_ems_id,
      :source              => 'DATAWAREHOUSE',
      :timestamp           => Time.zone.at(event.ctime / 1000),
      :event_type          => 'datawarehouse_event',
      :target_type         => target.class.name.underscore,
      :target_id           => target.id,
      :container_node_id   => target.id,
      :container_node_name => target.name,
      :message             => event.message,
      :full_data           => event.to_h
    }
  end

  def change_event(event)
    event.severity = event.tags[TAG_SEVERITY]
    event.message ||= event.text
  end

  def find_target(tags)
    target = TARGETS[tags[TAG_TYPE].to_sym]
    target_class = target[:target_class]
    target_key = target[:target_key]
    value = tags[target[:source_key]]
    target_class.find_by(target_key => value)
  end
end
