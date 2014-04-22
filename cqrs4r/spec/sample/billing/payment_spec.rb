require_relative '../../required'
require_relative 'events'
require_relative 'commands'
require_relative 'ar_payment'

describe 'when receives MakePaymentCommand' do

  it "should publish PaymentMadeEvent" do
    command_bus = CommandBus.new
    event_bus = EventBus.new
    repository = EventSourcingRepository.new
    repository.aggregate_root_type= Payment
    repository.event_bus=event_bus

    handler = anomynous_aggregate_root_handler repository
    handler.command_types.each do |command_type|
      command_bus.register_handler(command_type, handler)
    end

    order_id = '1'
    amount = 2
    type = 'CHECK'
    sequence = '23ds'

    expected_event = PaymentMadeEvent.new(sequence, order_id, amount, type)

    command_bus.dispatch(MakePaymentCommand.new(sequence, order_id, amount, type))

    event_bus.received.should eq([expected_event])
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
end
