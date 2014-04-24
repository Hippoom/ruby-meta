class RecordingEventBus
  
  def publish events
    @received = events
  end
  
  def received
    @received.nil?? []:@received.map {|event_message| event_message.payload}
  end
end

class SimpleEventBus
  def initialize
    @event_handlers = {}
  end

  def subscribe event_handler
    event_handler.event_types.each do |event_type|
      @event_handlers[event_type] = [] if @event_handlers[event_type].nil?
      @event_handlers[event_type] << event_handler
    end
  end

  def publish event_messages
    event_messages.each do |event_message|
      @event_handlers[event_message.payload.class].each do |handler|
        handler.send(:handle_event_message, event_message)
      end
    end
  end
end
