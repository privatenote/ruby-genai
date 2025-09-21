# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

require_relative "genai/version"
require_relative "genai/api_client"
require_relative "genai/client"

module Google
  module Genai
    # Your code goes here...
  end
end
