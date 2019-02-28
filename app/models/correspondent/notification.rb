# frozen_string_literal: true

module Correspondent
  # Notification
  #
  # Model to hold all notification logic.
  class Notification < ApplicationRecord
    belongs_to :subscriber, polymorphic: true
    belongs_to :publisher, polymorphic: true

    validates_presence_of :publisher, :subscriber

    scope :by_parents, ->(subscriber, publisher) { select(:id).where(subscriber: subscriber, publisher: publisher) }

    class << self
      # create_for!
      #
      # Creates notification(s) for the given
      # +instance+ of the publisher and given
      # +entity+ (subscriber).
      def create_for!(instance, entity, trigger, options = {})
        attributes = instance.to_notification(entity: entity, trigger: trigger)
        attributes[:publisher] = instance

        relation = instance.send(entity)

        if relation.respond_to?(:each)
          create_many!(attributes, relation, options)
        else
          create_single!(attributes, relation, options)
        end
      end

      # create_many!
      #
      # Creates a notification for each
      # record of the +relation+ so that
      # a many to many relationship can
      # notify all associated objects.
      def create_many!(attributes, relation, options)
        relation.each do |record|
          unless options[:avoid_duplicates] && by_parents(record, attributes[:publisher]).exists?
            create!(attributes.merge(subscriber: record))
          end
        end
      end

      # create_single!
      #
      # Creates a single notification for the
      # passed entity.
      def create_single!(attributes, relation, options)
        attributes[:subscriber] = relation
        create!(attributes) unless options[:avoid_duplicates] && by_parents(relation, attributes[:publisher]).exists?
      end
    end

    private_class_method :create_many!, :create_single!

    def to_json
      Rails.cache.fetch(self) do
        attributes.except("updated_at", "subscriber_type", "subscriber_id")
      end
    end
  end
end
