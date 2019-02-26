# frozen_string_literal: true

require "test_helper"

module Correspondent
  class Test < ActiveSupport::TestCase
    test "truth" do
      assert_kind_of Module, Correspondent
    end
  end
end
