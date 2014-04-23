require_relative '../required'

describe AggregateRoot do
  before(:each) do
    @ar = AnEventSourcedAggregateRoot.new
  end

  context 'when receives events' do
    it 'should be reconstituted from events' do
      @ar.send(:handle_event_message, DomainEventMessage.new('id', 1, CreatedEvent.new('id')))
      @ar.send(:handle_event_message, DomainEventMessage.new('id', 2, CreatedEvent.new('id')))

      @ar.id.should eq('id')
      @ar.version.should eq(2)
    end
  end
end

class CreatedEvent
  attr_reader :id
  def initialize id
    @id = id
  end
end

class AnUpdatedEvent
  attr_reader :id
  def initialize id
    @id = id
  end
end

class AnEventSourcedAggregateRoot
  include EventSourcedAggregateRoot

  identifier :id

  on CreatedEvent do |event|
    @id = event.id
  end
end

