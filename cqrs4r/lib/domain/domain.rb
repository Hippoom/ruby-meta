module AggregateRoot
  def initialize
    @events = []
  end

  attr_reader :events

  def apply event
    events << event
  end

  def commit
    @events = []
  end

  private :apply, :commit

  def self.included(clazz)

    clazz.class_eval do
      def self.create_on event
        self.new.tap do |aggregate|
          aggregate.send(:apply, event)#apply is private
        end
      end
    end
  end
end

module Repository
  attr_accessor :aggregate_root_type
  attr_accessor :event_bus
  
  def load id
    nil
  end

  def add aggregate_root
    event_bus.publish(aggregate_root.events)
    aggregate_root.send(:commit)
  end

  def store aggregate_root
    add aggregate_root
  end
  
  
end