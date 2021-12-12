# frozen_string_literal: true

require 'rake/testtask'

CODE = 'config/ app/'

task :default do
  puts `rake -T`
end

desc 'start the app with file chages watched'
task :dev do
  sh "rerun -c 'bundle exec rackup -p 4000' --ignore 'coverage/*' --ignore 'spec/*' --ignore '*.slim'"
end

desc 'run all quality checks'
task quality: 'quality:all'

desc 'Run application console (irb)'
task :console do
  sh 'pry -r ./init.rb'
end

desc 'Run all tests at once'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/tests/{integration,unit}/**/*_spec.rb'
  t.warning = false
end

desc 'Run all acceptance tests at once'
task :spec_accept do
  sh 'RACK_ENV=test rackup -o 127.0.0.1 -p 4000 &'
  sh 'rake test_acceptance'
  begin
    sh 'pkill -f "127\.0\.0\.1:4000"'
  rescue _e
    printf "\n\033[31m"
    puts 'Failed'
    puts 'Server not killed. please close it by yourself. (127.0.0.1:4000)'
    printf "\n\033[0m"
  end
end

Rake::TestTask.new(:test_acceptance) do |t|
  t.pattern = 'spec/tests/acceptance/**/*_spec.rb'
  t.warning = false
end

namespace :quality do
  task all: %i[rubocop flog reek]

  desc "flog: check #{CODE}"
  task :flog do
    sh "flog -m #{CODE}"
  end

  desc 'reek check'
  task :reek do
    sh 'reek'
  end

  desc 'rubocop check'
  task :rubocop do
    sh 'rubocop'
  end
end

namespace :vcr do
  desc 'delete all cassettes'
  task :clean do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'All cassettes deleted' : 'No cassette is found')
    end
  end
end
