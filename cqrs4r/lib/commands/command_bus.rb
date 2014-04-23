require_relative '../uow/uow'

class CommandBus
  def initialize
    @command_handlers = {}
  end

  def register_handler(command_type, handler)
    @command_handlers[command_type] = handler
  end

  def dispatch command
    uow = new_uow

    @command_handlers[command.class].send(:handle_command, command)

    commit uow
  end

  def new_uow
    uow = UnitOfWork.new
    Thread.current[:uow]= uow
    uow
  end
  
  def commit uow
    uow.commit
    Thread.current[:uow]= nil
  end
  
  private :new_uow, :commit
end

