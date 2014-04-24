require_relative '../../lib/events/event_store'

describe InMemoryEventStore do
  before(:each) do
    @event_store = InMemoryEventStore.new
    @events = [DomainEventMessage.new('identity', 1, 'event1'), DomainEventMessage.new('identity', 2, 'event2')]
    @event_store.append_events(AnAggregateRoot, @events)
  end

  subject {@event_store}

  context 'when read events' do

    it 'should return all events of a given aggregate root type and identity' do

      subject.read_events(AnAggregateRoot, 'identity').should eql(@events)
    end

    it 'should filter with given aggregate root type' do

      subject.read_events(AnotherAggregateRoot, 'identity').should eql([])

    end

    it 'should filter with given aggregate root identity' do

      subject.read_events(AnAggregateRoot, 'another_identity').should eql([])

    end
  end
end

class AnAggregateRoot;end

class AnotherAggregateRoot;end

