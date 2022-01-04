# frozen_string_literal: true

# Specify we are in test environment as the first thing in our spec setup
ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'cgi'
require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'
require 'yaml'
require 'http'

require_relative '../init'

# ENVIRONMENTAL
Figaro.application = Figaro::Application.new(
  environment: ENV,
  path: File.expand_path('config/secrets.yml')
)
Figaro.load
CONFIG = Figaro.env

# CONSTANTS
TEST_KEYWORD = 'backend engineer'
NEW_KEYWORD = 'frontend engineer'
INVALID_KEYWORD = '0000'
EMPTY_KEYWORD = ' '
EMPTY_RESULT_KEYWORD = 'asdf'
TEST_JOB_ID = 1110
INVALID_JOB_ID = 1000
TEST_SKILLSET = { 'name' => %w'python javascript' }