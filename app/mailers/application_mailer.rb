# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Babelfu.config.mailer_from
  layout "mailer"
end
