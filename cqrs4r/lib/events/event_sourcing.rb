require_relative '../domain/domain'
require_relative '../events/event_handling'

module EventSourcedAggregateRoot
  def self.included(clazz)
    clazz.class_eval do
      include AggregateRoot
      include EventHandling::EventHandler
    end
  end

end

class EventSourcingRepository
  include Repository
  
  attr_accessor :event_store
  
  def load id #override Repository
    ar = aggregate_root_type.new

    event_store.read_events(aggregate_root_type, id).each do |event|
      ar.send(:handle_event, event)
    end

    ar
  end

end
