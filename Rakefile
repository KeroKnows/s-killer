# frozen_string_literal: true

require 'rake/testtask'

## ------ CONFIGURATION ------ ##
CASSETTE_FOLDER = 'spec/fixtures/cassettes'
CODE = 'config/ app/'
HOST = '127.0.0.1'
DEV_PORT = '4000'
TEST_PORT = '4010'

## ------ ALIAS ------ ##
task :default do
  puts `rake -T`
end

desc 'alias to run:dev'
task dev: 'run:dev'

desc 'alias to quality:all'
task quality: 'quality:all'

desc 'alias to spec:all'
task spec: 'spec:all'

## ------ UTILITIES ------ ##
desc 'Run application console (irb)'
task :console do
  sh 'pry -r ./init.rb'
end

## ------ SERVING ------ ##
namespace :run do
  desc 'start the app with file chages watched'
  task :dev do
    sh "rerun -c 'rackup -p #{DEV_PORT}' --ignore 'coverage/*' --ignore 'spec/*' --ignore '*.slim'"
  end

  desc 'start the app with testing environment setting'
  task :test do
    sh "bundle exec rackup -p #{TEST_PORT}"
  end
end

## ------ TEST ------ ##
namespace :run do
  namespace :spec do
    # execute all integration and unit tests at once
    Rake::TestTask.new(:all) do |t|
      t.description = '' # hide this task from `rake -T`
      t.pattern = 'spec/tests/{integration,unit}/**/*_spec.rb'
      t.warning = false
    end

    # execute all unit tests at once.
    Rake::TestTask.new(:unit) do |t|
      t.description = '' # hide this task from `rake -T`
      t.pattern = 'spec/tests/unit/**/*_spec.rb'
      t.warning = false
    end

    # execute all integration tests at once
    Rake::TestTask.new(:integration) do |t|
      t.description = '' # hide this task from `rake -T`
      t.pattern = 'spec/tests/integration/**/*_spec.rb'
      t.warning = false
    end

    # execute acceptance tests at once.
    # Use spec:acceptance to start the test with server started for you
    Rake::TestTask.new(:acceptance) do |t|
      t.description = '' # hide this task from `rake -T`
      t.pattern = 'spec/tests/acceptance/**/*_spec.rb'
      t.warning = false
    end
  end
end

namespace :spec do
  desc 'run all unit and integration tests at once'
  task :all do
    sh 'RACK_ENV=test bundle exec rake run:spec:all'
  end

  desc 'run all unit tests at once'
  task :unit do
    sh 'RACK_ENV=test bundle exec rake run:spec:unit'
  end

  desc 'run all integration tests at once'
  task :integration do
    sh 'RACK_ENV=test bundle exec rake run:spec:integration'
  end

  desc 'run acceptance test'
  task :accept do
    # open server
    puts "[ INFO ] Running testing server on localhost:#{TEST_PORT}"
    sh "RACK_ENV=test bundle exec rackup -o #{HOST} -p #{TEST_PORT} &"
    # run test
    sh 'RACK_ENV=test bundle exec rake run:spec:acceptance'
  ensure
    # close the server
    begin
      uri = "#{HOST}:#{TEST_PORT}"
      sh "pkill -f \"#{Regexp.escape(uri)}\""
    rescue StandardError => _e
      printf "\n\033[31m"
      puts 'Failed'
      puts "Server not killed. please close it by yourself. (#{uri})"
      printf "\n\033[0m"
    end
  end
end

## ------ QUALITY ------ ##
namespace :quality do
  desc 'run all quality checks'
  task all: %i[rubocop flog reek]

  desc 'run rubocop check'
  task :rubocop do
    sh 'rubocop'
  end

  desc "run flog check of #{CODE}"
  task :flog do
    sh "flog -m #{CODE}"
  end

  desc 'run reek check'
  task :reek do
    sh 'reek'
  end
end

## ------ VCR ------ ##
namespace :vcr do
  desc 'list current casettes'
  task :list do
    sh "ls -1 #{CASSETTE_FOLDER}/*.yml"
  end

  desc 'delete all cassettes'
  task :clean do
    sh "rm #{CASSETTE_FOLDER}/*.yml" do |ok, _|
      puts(ok ? 'All cassettes deleted' : 'No cassette is found')
    end
  end
end
