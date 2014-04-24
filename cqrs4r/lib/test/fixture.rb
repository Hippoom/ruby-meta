require_relative '../commands/command_bus'
require_relative '../events/event_bus'
require_relative '../events/event_sourcing'

class Fixture
  def initialize aggregate_root_type
    @aggregate_root_type = aggregate_root_type
    @command_bus = CommandBus.new
    @event_bus = RecordingEventBus.new
    @event_store = RecordingEventStore.new
    @repository = EventSourcingRepository.new
    @repository.aggregate_root_type= @aggregate_root_type
    @repository.event_bus=@event_bus
    @repository.event_store=@event_store

    handler = anomynous_aggregate_root_handler(@repository)

    handler.command_types.each do |command_type|
      @command_bus.register_handler(command_type, handler)
    end
  end

  def anomynous_aggregate_root_handler repository
    handler = Object.new
    class <<handler
      include CommandHandling::AnonymousAggregateRootCommandHandler
      def command_types
        repository.aggregate_root_type.command_types
      end
    end
    handler.repository=repository
    handler
  end

  def given_events *events
    @event_store.append_events(@aggregate_root_type, events)
  end

  def when_receive command
    @command_bus.dispatch(command)
  end

  def then_received_events
    @event_bus.received
  end

  class RecordingEventStore
    def initialize
      @events = []
    end

    def read_events(aggregate_root_type, id)
      @events.map do |payload|
        DomainEventMessage.new(nil,nil,payload)
      end
    end

    def append_events aggregate_root_type, events
      @events.concat(events)
    end
  end
end