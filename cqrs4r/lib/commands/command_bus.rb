require_relative '../uow/uow'

class CommandBus
  def initialize
    @command_handlers = {}
  end

  def register_handler(command_type, handler)
    @command_handlers[command_type] = handler
  end

  def dispatch command
    create_uow

    @command_handlers[command.class].send(:handle_command, command)

    commit_uow
  end

  private

  def create_uow
    CurrentUnitOfWork.create
  end

  def commit_uow
    CurrentUnitOfWork.get.commit
    CurrentUnitOfWork.clear
  end

end

