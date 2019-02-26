# frozen_string_literal: true

module Correspondent
  # Notification
  #
  # Model to hold all notification logic.
  class Notification < ApplicationRecord
    belongs_to :subscriber, polymorphic: true
    belongs_to :publisher, polymorphic: true

    validates_presence_of :publisher, :subscriber

    class << self
      # create_for!
      #
      # Creates notification(s) for the given
      # +instance+ of the publisher and given
      # +entity+ (subscriber).
      def create_for!(instance, entity)
        attributes = instance.to_notification
        attributes[:publisher] = instance

        relation = instance.send(entity)

        if relation.respond_to?(:each)
          create_many!(attributes, relation)
        else
          create_single!(attributes, relation)
        end
      end

      # create_many!
      #
      # Creates a notification for each
      # record of the +relation+ so that
      # a many to many relationship can
      # notify all associated objects.
      def create_many!(attributes, relation)
        relation.each do |record|
          create!(attributes.merge(subscriber: record))
        end
      end

      # create_single!
      #
      # Creates a single notification for the
      # passed entity.
      def create_single!(attributes, relation)
        attributes[:subscriber] = relation
        create!(attributes)
      end
    end

    private_class_method :create_many!, :create_single!
  end
end
