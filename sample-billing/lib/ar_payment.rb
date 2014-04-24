require 'events/event_sourcing'
require 'commands/command_handling'
require 'commands'
require 'events'

class Payment
  include EventSourcedAggregateRoot
  include CommandHandling::AggregateRootCommandHandler
  
  identifier :sequence
  
  from MakePaymentCommand do |command|
    apply PaymentMadeEvent.new(command.sequence,command.order_id,command.amount,command.type)
  end

  handle ModifyPaymentAmountCommand do |command|
    
    if closed? then
      raise PaymentClosedException.new(@sequence), 'Cannot modify amount of [' + @sequence + '] as it is closed.'
    else
      apply PaymentAmountModifiedEvent.new(command.sequence, command.amount)
    end
  end

  handle ClosePaymentCommand do |command|
    apply PaymentClosedEvent.new(command.sequence)
  end

  on PaymentMadeEvent do |event|
    @sequence = event.sequence
    @order_id = event.order_id
    @amount = event.amount
    @type = event.type
    @status = 'NEW'
  end

  on PaymentClosedEvent do |event|
    @status = 'CLOSED'
  end

  def closed?
    return 'CLOSED' == @status
  end
end

class PaymentClosedException < StandardError
  def initialize sequence
    @sequence = sequence
  end
end