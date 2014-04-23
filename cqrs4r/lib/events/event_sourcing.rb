require_relative '../domain/domain'
require_relative '../events/event_handling'

module EventSourcedAggregateRoot
  def self.included(clazz)
    clazz.class_eval do
      include AggregateRoot
      include EventHandling::EventHandler
      
      def handle_event_message message
        self.send(:version=, message.sequence)
        self.send(:handle_event, message.payload)
      end
      
      #alias_method :handle_event_message, :handle_event
    end
  end

end

class EventSourcingRepository
  include Repository

  attr_accessor :event_store
  
  def do_load id #override Repository
    ar = aggregate_root_type.new

    event_store.read_events(aggregate_root_type, id).each do |event|
      ar.send(:handle_event, event.payload)
    end
    ar
  end
  
  def save aggregate_root
    event_store.append_events(aggregate_root.class, aggregate_root.send(:uncommitted_events))
  end
  
  private :do_load

end
