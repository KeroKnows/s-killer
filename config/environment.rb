# frozen_string_literal: true

# https://github.com/laserlemon/figaro

require 'roda'
require 'yaml'
require 'figaro'
require 'sequel'
require 'delegate'

module Skiller
  # Configuration for the App
  class App < Roda
    plugin :environments

    configure do
      # Environment variables setup
      Figaro.application = Figaro::Application.new(
        environment: environment,
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load

      # Make the environment variables accessible
      def self.config
        Figaro.env
      end
    end

    use Rack::Session::Cookie, secret: config.SESSION_SECRET
  end
end
