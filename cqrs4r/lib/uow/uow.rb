class UnitOfWork
  
  def commit
    @event_bus.publish(@aggregate_root.send(:uncommitted_events))
    @aggregate_root_saver.save(@aggregate_root)
    @aggregate_root.send(:commit_events)
  end
  
  def track(aggregate_root, event_bus, aggregate_root_saver)
    @aggregate_root = aggregate_root
    @event_bus = event_bus
    @aggregate_root_saver = aggregate_root_saver
  end
end