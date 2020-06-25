ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/reporters'

Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

FIXTURE_ORDERED_LOAD = %w[
  users
  pages
  drafts
  events
  event_managers
  resources
  resource_activations
  questions
  survey_templates
  survey_template_questions
  answers
].freeze

class ActiveSupport::TestCase
  fixtures FIXTURE_ORDERED_LOAD
end


class DevisedTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  fixtures FIXTURE_ORDERED_LOAD
end
