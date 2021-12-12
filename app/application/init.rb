# frozen_string_literal: true

folders = %w[representers forms services controllers]
folders.each do |folder|
  require_relative "#{folder}/init"
end
