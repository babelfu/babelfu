# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
if ENV["RAILS_ENV"] == "test"
  require "simplecov"
  SimpleCov.start("rails")
end

require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)
    parallelize_setup do |worker|
      SimpleCov.command_name("#{SimpleCov.command_name}-#{worker}")
      ActiveRecord::Migration.create_table :dummy_syncable_models, force: true do |t|
        t.string :name
        t.timestamps
      end
    end

    parallelize_teardown do |_worker|
      SimpleCov.result
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end
