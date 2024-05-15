# frozen_string_literal: true

require "babelfu/config"
module Babelfu
  class << self
    def config
      @config ||= Config.new
    end
  end
end
