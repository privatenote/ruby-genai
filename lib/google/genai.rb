# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

require_relative "genai/version"
require_relative "genai/api_client"
require_relative "genai/models"
require_relative "genai/chats"
require_relative "genai/files"
require_relative "genai/tunings"
require_relative "genai/caches"
require_relative "genai/batches"
require_relative "genai/operations"
require_relative "genai/tokens"
require_relative "genai/live"
require_relative "genai/client"

module Google
  module Genai
    # Your code goes here...
  end
end
