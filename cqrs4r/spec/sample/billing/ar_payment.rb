class Payment
  include EventSourcedAggregateRoot
  include CommandHandling::AggregateRootCommandHandler

  from MakePaymentCommand do |command|
    apply PaymentMadeEvent.new(command.sequence,command.order_id,command.amount,command.type)
  end

  handle ModifyPaymentAmountCommand do |command|
    apply PaymentAmountModifiedEvent.new(command.sequence, command.amount)
  end

  on PaymentMadeEvent do |event|
    @sequence = event.sequence
    @order_id = event.order_id
    @amount = event.amount
    @type = event.type
  end
end