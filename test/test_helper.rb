#
#ENV["RAILS_ENV"] = "test"

require 'simplecov'
SimpleCov.start 'rails'
# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
