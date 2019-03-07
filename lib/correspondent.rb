# frozen_string_literal: true

require "correspondent/engine"

module Correspondent # :nodoc:
  class << self
    attr_writer :patched_methods, :fiber, :queue

    # patched_methods
    #
    # Hash with information about methods
    # that need to be patched.
    def patched_methods
      @patched_methods ||= {}.with_indifferent_access
    end

    # fiber
    #
    # Defines the fiber used for processing
    # the notifications' queue in the background.
    def fiber
      @fiber ||= Fiber.new do
        loop do
          data = queue.shift

          unless data.dig(:options, :email_only)
            Correspondent::Notification.create_for!(data.except(:options), data[:options])
          end

          trigger_email(data) if data.dig(:options, :mailer)

          Fiber.yield if queue.empty?
        end
      end
    end

    # trigger_email
    #
    # Calls the method of a given mailer using the
    # trigger. Triggering only happens if a mailer
    # has been passed as an option.
    #
    # Will invoke methods in this manner:
    #
    # MyMailer.send("make_purchase_email", #<Purchase id: 1...>)
    def trigger_email(data)
      data.dig(:options, :mailer).send("#{data[:trigger]}_email", data[:instance]).deliver_now
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
    # into the queue and resume the Fiber processing.
    def <<(payload)
      queue << payload
      fiber.resume
    end
  end

  # notifies
  #
  # Hook to patch the desired method +triggers+
  # to push notification creations into the queue.
  #
  # This will patch the methods +triggers+ to publish
  # notifications using the method_added callback.
  # Upon each +triggers+ method definition, the callback
  # runs and patches the original method.
  # If already patched, doesn't do anything (to avoid infinite loops).

  # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
  def notifies(entity, triggers, options = {})
    save_trigger_info(entity, triggers, options)

    unless method_defined?(:method_added)
      class_eval do
        # Method patching
        #
        # For each trigger method
        # 1. Capture unbound instance method
        # 2. Add it to patched methods to avoid trying to patch it again
        # 3. Undefine it to avoid re-definition warnings
        # 4. Define method again invoking original implementation and
        #    inserting a new payload in the queue to be processed by the Fiber.
        def self.method_added(name)
          if Correspondent.patched_methods.key?(name)
            original_method = instance_method(name)
            undef_method(name)
            patch_info = Correspondent.patched_methods.delete(name)

            define_method(name) do |*args|
              original_method.bind(self).call(*args).tap do
                patch_info.each do |info|
                  Correspondent << {
                    instance: self,
                    entity: info[:entity],
                    trigger: name,
                    options: info[:options]
                  }
                end
              end
            end
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/MethodLength,Metrics/AbcSize

  # ActiveRecord on load hook
  #
  # Extend the module after load so that
  # model class methods are available.
  ActiveSupport.on_load(:active_record) do
    extend Correspondent
  end

  private

  # save_trigger_info
  #
  # Saves trigger information in hash for future patching.
  def save_trigger_info(entity, triggers, options)
    triggers = [triggers] unless triggers.is_a?(Array)

    triggers.each do |trigger|
      Correspondent.patched_methods[trigger] ||= []
      Correspondent.patched_methods[trigger] << { entity: entity, options: options }
    end
  end
end
