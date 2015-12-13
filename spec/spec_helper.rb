require 'rubygems'
require 'bundler'
require 'pry'
Bundler.setup

require 'redis_examples'

RSpec.configure do |config|
  config.mock_with :rspec
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end

