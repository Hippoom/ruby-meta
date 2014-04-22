class MakePaymentCommand
  attr_reader :sequence
  attr_reader :order_id
  attr_reader :amount
  attr_reader :type
  
  def initialize(sequence,order_id, amount, type)
    @sequence=sequence
    @order_id=order_id
    @amount = amount
    @type=type
  end
end

class ModifyPaymentAmountCommand
  include CommandHandling::AnonymousAggregateRootCommand
  attr_reader :sequence
  attr_reader :amount
  
  def initialize(sequence, amount)
    @sequence=sequence
    @amount = amount
  end
end