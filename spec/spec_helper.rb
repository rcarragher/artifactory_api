require File.expand_path('../../lib/artifactory_api', __FILE__)
require 'logger'

RSpec.configure do |config|
  config.mock_with :rspec
  config.color_enabled = true
  config.order = :random
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
end

