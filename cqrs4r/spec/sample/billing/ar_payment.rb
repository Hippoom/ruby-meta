class Payment
  include EventSourcedAggregateRoot
  include CommandHandling::AggregateRootCommandHandler

  from MakePaymentCommand do |command|
    apply PaymentMadeEvent.new(command.sequence,command.order_id,command.amount,command.type)
  end
end