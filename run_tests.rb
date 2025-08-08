#!/usr/bin/env ruby

# Simple test runner for Solana-Ruby
# Usage: ruby run_tests.rb

require 'rspec/core'

# Add the lib directory to the load path
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

# Load the gem
require 'solana-ruby'

# Configure RSpec
RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
  config.order = :random
end

# Run the tests
puts "Running Solana-Ruby tests..."
puts "=" * 50

# Run all spec files
spec_files = Dir[File.join(File.dirname(__FILE__), 'spec', '**', '*_spec.rb')]
spec_files.each do |spec_file|
  puts "Running tests from: #{spec_file}"
  load spec_file
end

puts "=" * 50
puts "Test execution completed!"
