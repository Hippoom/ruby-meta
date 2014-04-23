module AggregateRoot
  def initialize
    @uncommitted_events = []
  end

  attr_reader :uncommitted_events
  attr_writer :version

  def apply event_payload
    uncommitted_events << DomainEventMessage.new(identifier, next_event_sequence, event_payload)
  end

  def commit_events
    @uncommitted_events = []
  end

  def identifier
    send(self.class.identifier_symbol)
  end

  def next_event_sequence
    version + 1
  end

  def version
    @version || 1
  end

  private :apply, :commit_events, :uncommitted_events, :next_event_sequence, :version=

  def self.included(clazz)

    clazz.class_eval do
      def self.create_on event
        self.new.tap do |aggregate|
          aggregate.send(:apply, event)#apply is private
        end
      end

      def self.identifier symbol

        attr_reader symbol

        @identifier_symbol = symbol
      end

      def self.identifier_symbol
        @identifier_symbol
      end
    end
  end
end

module Repository
  attr_accessor :aggregate_root_type
  attr_accessor :event_bus
  def load id
    ar = do_load(id)
    current_uow.track(ar, event_bus, self)
    ar
  end

  def add aggregate_root
    current_uow.track(aggregate_root, event_bus, self)
  end

  def current_uow
    Thread.current[:uow]
  end
end

class DomainEventMessage
  attr_reader :aggregate_root_identitifer
  attr_reader :sequence
  attr_reader :payload
  def initialize (aggregate_root_identitifer, sequence, payload)
    @aggregate_root_identitifer = aggregate_root_identitifer
    @sequence = sequence
    @payload = payload
  end
end