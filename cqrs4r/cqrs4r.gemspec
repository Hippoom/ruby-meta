Gem::Specification.new do |s|  
  s.name = 'cqrs4r'  
  s.version = '0.0.1'  
  s.date = '2014-04-24'  
  s.summary = 'A simple cqrs framework as a study project.'  
  s.author = 'Hippoom'
  s.files = [  
    'lib/commands/command_bus.rb',
    'lib/commands/command_handling.rb',
    'lib/domain/domain.rb',
    'lib/events/event_bus.rb',
    'lib/events/event_handling.rb',
    'lib/events/event_sourcing.rb',
    'lib/events/event_store.rb',
    'lib/uow/uow.rb', 
    'lib/test/fixture.rb' 
  ]  
  s.require_paths = ["lib"]  
end