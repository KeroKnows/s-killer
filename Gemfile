# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Developing tools
group :development do
  gem 'pry', '~> 0.13.1'
end

# Web App
gem 'figaro', '~> 1.2'
gem 'puma', '~> 5.5'
gem 'roda', '~> 3.49'
gem 'slim', '~> 4.1'

# Representing
gem 'multi_json', '~> 1.15'
gem 'roar', '~> 1.1'

# Validation
gem 'dry-transaction', '~> 0.13'
gem 'dry-validation', '~> 1.7'

# Networking
gem 'http', '~> 5.0'

# Testing
group :test do
  gem 'minitest', '~> 5.0'
  gem 'minitest-rg', '~> 5.0'
  gem 'page-object', '~> 2.3'
  gem 'simplecov', '~> 0'
  gem 'vcr', '~> 6.0'
  gem 'watir', '~> 7.0'
  gem 'webdrivers', '~> 5.0'
  gem 'webmock', '~> 3.0'
end

# Utilities
gem 'rake'

def os_is(pattern)
  RbConfig::CONFIG['host_os'] =~ pattern ? true : false
end
group :development do
  gem 'rb-fsevent', platforms: :ruby, install_if: os_is(/darwin/)
  gem 'rb-kqueue', platforms: :ruby, install_if: os_is(/linux/)
  gem 'rerun'
end
gem 'nokogiri', '~> 1.12'

# Code Quality
group :development do
  gem 'flog'
  gem 'reek'
  gem 'rubocop'
end
