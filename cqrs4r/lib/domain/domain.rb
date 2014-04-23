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
    ar = do_load(id)
    current_uow.track(ar, event_bus)
    ar
  end

  def add aggregate_root
    current_uow.track(aggregate_root, event_bus)
  end
  
  def current_uow
    Thread.current[:uow]
  end
end