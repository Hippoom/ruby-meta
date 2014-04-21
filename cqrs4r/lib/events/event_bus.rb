class EventBus
  attr_reader :received
  
  def publish events
    @received = events
  end
end
