# frozen_string_literal: true

require "correspondent/engine"

module Correspondent # :nodoc:
  class << self
    attr_writer :patched_methods, :fiber, :queue

    # patched_methods
    #
    # List to keep track of methods that
    # have been patched with notification
    # instrumentation.
    def patched_methods
      @patched_methods ||= []
    end

    def fiber
      @fiber ||= Fiber.new do
        loop do
          data = queue.shift

          Correspondent::Notification.create_for!(
            data[:instance],
            data[:entity],
            data[:trigger],
            data[:options]
          )

          Fiber.yield if queue.empty?
        end
      end
    end

    # queue
    #
    # List of payloads that need to be processed
    # in the background for creating notifications.
    def queue
      @queue ||= []
    end

    # <<
    #
    # Define the << operator to insert +payload+
    # into the queue and spawn the processing
    # thread if necessary.
    def <<(payload)
      queue << payload
      fiber.resume
    end
  end

  # notifies
  #
  # Hook to patch the desired method triggers
  # and publish / subscribe to notifications.
  #
  # This will patch the methods +triggers+ to publish
  # notifications using the method_added callback.
  # Upon each +triggers+ method definition, the callback
  # runs and patches the original method adding instrumentation.
  # If already patched, doesn't do anything (to avoid infinite loops).

  # rubocop:disable Style/ClassVars,Metrics/MethodLength,Style/Next,Metrics/AbcSize
  def notifies(entity, triggers, options = {})
    triggers = [triggers] unless triggers.is_a?(Array)

    class_eval do
      # Save parameters for temporary class usage
      @@entity = entity
      @@triggers = triggers
      @@options = options

      # Define the hook to capture method after
      # definition. Capture original method,
      # add to the patched list to avoid infinite
      # loop and undefine original implementation.
      # Finally, redefine method surrounding with
      # instrumentation block.
      def self.method_added(name)
        @@triggers.each do |trigger|
          if name == trigger && Correspondent.patched_methods.exclude?(trigger)
            original_method = instance_method(trigger)
            Correspondent.patched_methods << trigger

            undef_method(trigger)
            entity = @@entity
            options = @@options

            define_method trigger do |*args|
              original_method.bind(self).call(*args).tap do
                Correspondent << {
                  instance: self,
                  entity: entity,
                  trigger: trigger,
                  options: options
                }
              end
            end
          end
        end
      end
    end
  end
  # rubocop:enable Style/ClassVars,Metrics/MethodLength,Style/Next,Metrics/AbcSize

  # ActiveRecord on load hook
  #
  # Extend the module after load so that
  # model class methods are available.
  ActiveSupport.on_load(:active_record) do
    extend Correspondent
  end
end
