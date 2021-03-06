require 'rubygems'
require 'bundler'
require 'pry'
Bundler.setup
require 'redis'
require 'ostruct'
require 'json'

# Require support classes
Dir[File.dirname(__FILE__) + '/support/*.rb'].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end

