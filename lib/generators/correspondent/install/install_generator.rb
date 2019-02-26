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
      end

      def migration_version
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
      end
    end
  end
end
