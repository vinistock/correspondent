# frozen_string_literal: true

module Correspondent
  class ApplicationRecord < ActiveRecord::Base # :nodoc:
    self.abstract_class = true
  end
end
