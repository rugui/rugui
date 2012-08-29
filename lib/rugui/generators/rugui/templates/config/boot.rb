require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

APPLICATION_ROOT = File.expand_path('../..', __FILE__) unless defined?(APPLICATION_ROOT)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])