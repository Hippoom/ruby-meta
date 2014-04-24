require_relative '../../lib/events/event_bus'

describe SimpleEventBus do
  before(:each) do
    @event_bus = SimpleEventBus.new
  end

  context 'when receive events' do
    it 'should publish them to corresponding handlers' do
      an_event = DomainEventMessage.new('id',1, SampleEvent.new('event1'))
      another_event = DomainEventMessage.new('id',2, SampleEvent.new('event2'))

      a_handler = HandlerForSampleEvent.new
      another_handler = HandlerForSampleEvent.new
      an_irrelevant_handler = HandlerForOtherSampleEvent.new

      @event_bus.subscribe(a_handler)
      @event_bus.subscribe(another_handler)
      @event_bus.subscribe(an_irrelevant_handler)

      @event_bus.publish [an_event, another_event]

      a_handler.received.should eql([an_event.payload(), another_event.payload()])
      another_handler.received.should eql([an_event.payload(), another_event.payload()])
      an_irrelevant_handler.received.should be_nil
    end
  end
end

class SampleEvent
  attr_reader :content
  def initialize content
    @content = content
  end
end

class HandlerForSampleEvent
  include EventHandling::EventHandler
  def initialize
    @received = []
  end

  attr_reader :received

  on SampleEvent do |event|
    @received << event
  end
end

class OtherSampleEvent
  attr_reader :content
  def initialize content
    @content = content
  end
end

class HandlerForOtherSampleEvent
  include EventHandling::EventHandler

  attr_reader :received

  on OtherSampleEvent do |event|
    @received = event
  end
end