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

    uow.commit
  end

  def new_uow
    uow = UnitOfWork.new
    current_thread = Thread.current
    current_thread[:uow]= uow
    uow
  end
end

