# frozen_string_literal: true

module Babelfu
  class << self
    def config
      @config ||= Config.new
    end
  end
end
