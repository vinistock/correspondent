# frozen_string_literal: true

require "rails/generators/migration"

module Correspondent
  module Generators
    # InstallGenerator
    #
    # Creates the necessary migrations to be able to
    # use the engine.
    class InstallGenerator < ::Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)
      desc "Create Correspondent migrations"

      def self.next_migration_number(_path)
        if @prev_migration_nr
          @prev_migration_nr += 1
        else
          @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
        end

        @prev_migration_nr.to_s
      end

      def copy_migrations
        migration_template "create_correspondent_notifications.rb",
                           "db/migrate/create_correspondent_notifications.rb",
                           migration_version: migration_version

        say "\n"
        say <<~POST_INSTALL_MESSAGE
          Make sure to edit the generated migration and adapt the notifications
          attributes according to the application's need. The only attributes
          that must be kept are the one listed below and the indices.

          Any other desired attributes can be added and then referenced in the
          `to_notification` method.

            publisher_type
            publisher_id
            subscriber_type
            subscriber_id
        POST_INSTALL_MESSAGE
      end

      def migration_version
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
      end
    end
  end
end
