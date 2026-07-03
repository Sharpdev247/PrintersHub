ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Temporarily set ENV variables for the duration of a block.
    def with_env(vars)
      old = vars.keys.map { |k| [ k.to_s, ENV[k.to_s] ] }.to_h
      vars.each { |k, v| v.nil? ? ENV.delete(k.to_s) : ENV[k.to_s] = v.to_s }
      yield
    ensure
      old.each { |k, v| v.nil? ? ENV.delete(k) : ENV[k] = v }
    end
  end
end
