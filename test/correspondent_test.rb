# frozen_string_literal: true

require "test_helper"

module Correspondent
  class Test < ActiveSupport::TestCase
    test "adds hook to extend module after ar load" do
      purchase = Purchase.new
      assert defined?(purchase.class.notifies)
    end

    test "#notifies" do
      purchase = Purchase.new
      method_source = purchase.method(:purchase).source
      assert method_source.include?("ActiveSupport::Notifications.instrument")
      assert purchase.purchase
    end
  end
end
