class EventStore
  def initialize
    @events = []
  end
  
  def read_events(aggregate_root_type, id)
    @events
  end

  def append_events aggregate_root_type, events
    @events.concat(events)
  end
end