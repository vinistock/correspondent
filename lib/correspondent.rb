# frozen_string_literal: true

require "correspondent/engine"

module Correspondent # :nodoc:
  class << self
    attr_writer :patched_methods

    # patched_methods
    #
    # List to keep track of methods that
    # have been patched with notification
    # instrumentation.
    def patched_methods
      @patched_methods ||= []
    end
  end

  # notifies
  #
  # Hook to patch the desired method triggers
  # and publish / subscribe to notifications
  # using ActiveSupport's API.
  #
  # This will patch the method +trigger+ to publish
  # notifications using the method_added callback.
  # Upon the +trigger+ method definition, the callback
  # runs and patches the original method adding instrumentation.
  # If already patched, doesn't do anything (to avoid infinite loops).

  # rubocop:disable Style/ClassVars,Metrics/MethodLength
  def notifies(entity, trigger)
    class_eval do
      # Save parameters for temporary class usage
      @@entity = entity
      @@trigger = trigger

      # Define the hook to capture method after
      # definition. Capture original method,
      # add to the patched list to avoid infinite
      # loop and undefine original implementation.
      # Finally, redefine method surrounding with
      # instrumentation block.
      def self.method_added(name)
        if name == @@trigger && Correspondent.patched_methods.exclude?(@@trigger)
          original_method = instance_method(@@trigger)
          Correspondent.patched_methods << @@trigger

          undef_method(@@trigger)

          define_method @@trigger do |*args|
            ActiveSupport::Notifications.instrument("#{self.class}##{@@trigger}_on_#{@@entity}") do
              original_method.bind(self).call(*args)
            end
          end
        end
      end
    end

    ActiveSupport::Notifications.subscribe("#{self}##{trigger}_on_#{entity}") do |name, start, finish, id, payload|
    end
  end
  # rubocop:enable Style/ClassVars,Metrics/MethodLength

  # ActiveRecord on load hook
  #
  # Extend the module after load so that
  # model class methods are available.
  ActiveSupport.on_load(:active_record) do
    extend Correspondent
  end
end
