# frozen_string_literal: true

module Correspondent
  class Engine < ::Rails::Engine # :nodoc:
    isolate_namespace Correspondent
    config.generators.api_only = true
  end
end
