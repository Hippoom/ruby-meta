require_relative '../../required'
require_relative 'events'
require_relative 'commands'


describe 'when receives MakePaymentCommand' do

  it "should publish PaymentMadeEvent" do
    command_bus = CommandBus.new
    event_bus = EventBus.new

    order_id = '1'
    amount = 2
    type = 'CHECK'
    sequence = '23ds'

    expected_event = PaymentMadeEvent.new(sequence, order_id, amount, type)

    command_bus.dispatch(MakePaymentCommand.new(order_id, amount, type))

    event_bus.received.should equal(expected_event)
  end

end
