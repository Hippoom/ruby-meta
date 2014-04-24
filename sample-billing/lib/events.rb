class PaymentMadeEvent
  attr_reader :sequence
  attr_reader :order_id
  attr_reader :amount
  attr_reader :type
  def initialize(sequence, order_id, amount, type)
    @sequence=sequence
    @order_id=order_id
    @amount=amount
    @type=type
  end

  def ==(o)
    o.class == self.class && o.state == o.state
  end

  def hash
    state.hash
  end

  def state
    [@sequence, @order_id, @amount, @type]
  end

end

class PaymentAmountModifiedEvent
  attr_reader :sequence
  attr_reader :amount
  def initialize(sequence, amount)
    @sequence=sequence
    @amount=amount
  end

  def ==(o)
    o.class == self.class && o.state == o.state
  end

  def hash
    state.hash
  end

  def state
    [@sequence, @amount]
  end

end

class PaymentClosedEvent
  attr_reader :sequence
  def initialize(sequence)
    @sequence=sequence
  end

  def ==(o)
    o.class == self.class && o.state == o.state
  end

  def hash
    state.hash
  end

  def state
    [@sequence]
  end

end