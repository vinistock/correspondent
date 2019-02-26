# frozen_string_literal: true

module Correspondent
  class ApplicationMailer < ActionMailer::Base # :nodoc:
    default from: "from@example.com"
    layout "mailer"
  end
end
