require_relative '../lib/events'
require_relative '../lib/commands'
require_relative '../lib/ar_payment'
require 'test/fixture'

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