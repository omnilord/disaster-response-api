ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

FIXTURE_ORDERED_LOAD = %w[
  users
  pages
  drafts
  events
  event_managers
  resources
  resource_activations
].freeze

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures FIXTURE_ORDERED_LOAD

  # Add more helper methods to be used by all tests here...
end


class DevisedTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  fixtures FIXTURE_ORDERED_LOAD
end
