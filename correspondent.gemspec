# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "correspondent/version"

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name        = "correspondent"
  spec.version     = Correspondent::VERSION
  spec.authors     = ["Vinicius Stock"]
  spec.email       = ["vinicius.stock@outlook.com"]
  spec.homepage    = "https://github.com/vinistock/correspondent"
  spec.summary     = "Dead simple configurable user notifications with little overhead."
  spec.description = "Dead simple configurable user notifications with little overhead."
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*",
                   "MIT-LICENSE",
                   "Rakefile",
                   "README.md"]

  spec.add_dependency "async"
  spec.add_dependency "rails"

  spec.add_development_dependency "benchmark-ips"
  spec.add_development_dependency "brakeman"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "purdytest"
  spec.add_development_dependency "rails_best_practices"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-minitest"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rails"
  spec.add_development_dependency "simplecov", "~> 0.17.0"
end
# rubocop:enable Metrics/BlockLength
