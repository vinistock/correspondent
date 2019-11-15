# frozen_string_literal: true

require "correspondent/engine"
require "async"

module Correspondent # :nodoc:
  LAMBDA_PROC_REGEX = /(->.*})|(->.*end)|(proc.*})|(proc.*end)|(Proc\.new.*})|(Proc\.new.*end)/.freeze

  class << self
    attr_writer :patched_methods

    # patched_methods
    #
    # Hash with information about methods
    # that need to be patched.
    def patched_methods
      @patched_methods ||= {}.with_indifferent_access
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

    # <<
    #
    # Adds the notification creation and email sending
    # as asynchronous tasks.
    def <<(data)
      Async do
        unless data.dig(:options, :email_only)
          Correspondent::Notification.create_for!(data.except(:options), data[:options])
        end

        trigger_email(data) if data.dig(:options, :mailer)
      end
    end

    # should_notify?
    #
    # Evaluates the if and unless options within
    # the context of a model instance.
    def should_notify?(context, opt)
      if opt[:if].present?
        evaluate_conditional(context, opt[:if])
      elsif opt[:unless].present?
        !evaluate_conditional(context, opt[:unless])
      end
    end

    # evaluate_conditional
    #
    # Evaluates if or unless regardless of
    # whether it is a proc or a symbol.
    def evaluate_conditional(context, if_or_unless)
      if if_or_unless.is_a?(Proc)
        context.instance_exec(&if_or_unless)
      else
        context.method(if_or_unless).call
      end
    end
  end

  # notifies
  #
  # Save trigger info and options into the patched_methods
  # hash.
  def notifies(entity, triggers, options = {})
    triggers = [triggers] unless triggers.is_a?(Array)

    triggers.each do |trigger|
      Correspondent.patched_methods[trigger] ||= []
      Correspondent.patched_methods[trigger] << { entity: entity, options: options }
    end
  end

  # method_added
  #
  # Callback to patch methods once they are defined.
  # 1. Create an alias of the original method
  # 2. Override method by calling the original
  # 3. Add Correspondent calls for notifications
  def method_added(name)
    patch_info = Correspondent.patched_methods.delete(name)
    return unless patch_info

    class_eval(<<~PATCH, __FILE__, __LINE__ + 1)
      alias_method :original_#{name}, :#{name}

      def #{name}(*args, &block)
        result = original_#{name}(*args, &block)
        #{build_async_calls(patch_info, name)}
        result
      end
    PATCH
  end

  # ActiveRecord on load hook
  #
  # Extend the module after load so that
  # model class methods are available.
  ActiveSupport.on_load(:active_record) do
    extend Correspondent
  end

  private

  # build_async_calls
  #
  # Builds all async call strings needed
  # to patch the method.
  def build_async_calls(patch_info, name) # rubocop:disable Metrics/AbcSize
    patch_info.map do |info|
      info[:options][:unless] = stringify_lambda(info[:options][:unless]) if info[:options][:unless].is_a?(Proc)
      info[:options][:if] = stringify_lambda(info[:options][:if]) if info[:options][:if].is_a?(Proc)

      async_call_string(info, name)
    end.join("\n")
  end

  # async_call_string
  #
  # Builds the string for an Async call
  # to send data to Correspondent callbacks.
  def async_call_string(info, name)
    <<~ASYNC_CALL
      if Correspondent.should_notify?(self, #{info[:options].to_s.delete('"')})
        Async do
          Correspondent << {
            instance: self,
            entity: :#{info[:entity]},
            trigger: :#{name},
            options: #{info[:options].to_s.delete('"')}
          }
        end
      end
    ASYNC_CALL
  end

  # stringify_lambda
  #
  # Transform lambda into a string to be used
  # in method patching.
  def stringify_lambda(lambda)
    lambda.source.scan(LAMBDA_PROC_REGEX).flatten.compact.first
  end
end
