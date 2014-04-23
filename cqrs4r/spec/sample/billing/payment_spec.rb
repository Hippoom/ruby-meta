require_relative '../../required'
require_relative 'events'
require_relative 'commands'
require_relative 'ar_payment'

class Fixture
  def initialize aggregate_root_type
    @aggregate_root_type = aggregate_root_type
    @command_bus = CommandBus.new
    @event_bus = RecordingEventBus.new
    @event_store = EventStore.new
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

end

describe Payment do
  before(:each) do
    @fixture = Fixture.new(Payment)
  end

  subject do
    @fixture
  end

  context 'when receives MakePaymentCommand' do
    it 'should publish PaymentMadeEvent' do

      order_id = '1'
      amount = 2
      type = 'CHECK'
      sequence = '23ds'

      @fixture.when_receive(MakePaymentCommand.new(sequence, order_id, amount, type))

      @fixture.then_received_events.should eq([PaymentMadeEvent.new(sequence, order_id, amount, type)])
    end
  end

  context 'when receives ClosePaymentCommand' do
    it 'should publish PaymentClosedEvent' do

      order_id = '1'
      amount = 2
      type = 'CHECK'
      sequence = '23ds'

      @fixture.given_events(PaymentMadeEvent.new(sequence, order_id, amount, type))

      @fixture.when_receive(ClosePaymentCommand.new(sequence))

      @fixture.then_received_events.should eq([PaymentClosedEvent.new(sequence)])
    end
  end

  context 'when receives ModifyPaymentAmountCommand' do

    it 'should publish PaymentAmountModifiedEvent' do

      order_id = '1'
      amount = 2
      type = 'CHECK'
      sequence = '23ds'

      modified = 3

      @fixture.given_events(PaymentMadeEvent.new(sequence, order_id, amount, type))

      @fixture.when_receive(ModifyPaymentAmountCommand.new(sequence, modified))

      @fixture.then_received_events.should eq([PaymentAmountModifiedEvent.new(sequence, modified)])
    end

    context 'given the payment has been closed' do
      it 'should throw PaymentClosedException' do

        order_id = '1'
        amount = 2
        type = 'CHECK'
        sequence = '23ds'

        modified = 3

        @fixture.given_events(PaymentMadeEvent.new(sequence, order_id, amount, type), PaymentClosedEvent.new(sequence))

        expect {@fixture.when_receive(ModifyPaymentAmountCommand.new(sequence, modified))}.to raise_error('Cannot modify amount of [' + sequence + '] as it is closed.')

      end
    end
  end

end