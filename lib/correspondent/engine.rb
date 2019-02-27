# frozen_string_literal: true

module Correspondent
  class Engine < ::Rails::Engine # :nodoc:
    # Must eager load the notification model
    require_relative "../../app/models/correspondent/application_record"
    require_relative "../../app/models/correspondent/notification"

    isolate_namespace Correspondent
    config.generators.api_only = true
  end
end
