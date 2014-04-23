class InMemoryEventStore
  def initialize
    @events = {}
  end

  def read_events(aggregate_root_type, id)
    return [] if @events[aggregate_root_type].nil?
    @events[aggregate_root_type].select do |event|
      event.aggregate_root_identitifer == id
    end
  end

  def append_events aggregate_root_type, events
    @events[aggregate_root_type] = [] if @events[aggregate_root_type].nil?
    @events[aggregate_root_type].concat(events)
  end
end