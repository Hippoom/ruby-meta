module CommandHandling
  module AnonymousAggregateRootCommand
    def self.included(clazz)
      clazz.class_eval do
        def self.target_aggregate_root_identity symbol
          attr_reader symbol

          define_method:target_aggregate_root_identity do
            send(symbol)
          end
        end
      end
    end
  end

  module AggregateRootCommandHandler
    def self.included(clazz)
      clazz.class_eval do
        include CommandHandler
        def self.from(command_type, &handler)
          handle(command_type, &handler)
        end

        define_singleton_method :create_from do |command|
          ar = clazz.new
          ar.send(:handle_command, command)
          ar
        end
      end
    end
  end

  module AnonymousAggregateRootCommandHandler
    attr_accessor :repository
    def handle_command command
      if command.respond_to?(:target_aggregate_root_identity) then
        delegate_to_ar_to_handle command
      else
        create_new_ar_with command
      end
    end

    def create_new_ar_with command
      ar = repository.aggregate_root_type.create_from(command)
      repository.add ar
    end

    def delegate_to_ar_to_handle command
      ar  = repository.load(command.target_aggregate_root_identity)
      ar.send(:handle_command,command)
      repository.store ar
    end
  end

  module CommandHandler
    def self.included(clazz)
      clazz.class_eval do
        @command_handlers = {}

        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
      def command_handler_for command
        @command_handlers[command.class]
      end

      def handle(command_type, &handler)
        @command_handlers[command_type] = handler
      end
      
      def command_types
        @command_handlers.keys
      end

      private :handle, :command_handler_for
    end

    module InstanceMethods
      def handle_command command
        handler = command_handler_for command
        instance_exec(command, &handler)
      end

      def command_handler_for command
        self.class.send(:command_handler_for, command)
      end

      private :handle_command, :command_handler_for
    end
  end
end
