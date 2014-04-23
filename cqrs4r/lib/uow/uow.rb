class UnitOfWork
  
  def commit
    @event_bus.publish(@tracking.events)
  end
  
  def track(aggregate_root, event_bus)
    @tracking = aggregate_root
    @event_bus = event_bus
  end
end