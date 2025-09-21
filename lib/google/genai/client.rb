# frozen_string_literal: true

require_relative "api_client"
require_relative "genai/models"
require_relative "genai/chats"
require_relative "genai/files"
require_relative "genai/tunings"
require_relative "genai/caches"
require_relative "genai/batches"
require_relative "genai/operations"
require_relative "genai/tokens"
require_relative "genai/live"
# ... other requires will be added here

module Google
  module Genai
    class Client
      def initialize(api_key: nil, vertexai: nil, credentials: nil, project: nil, location: nil, http_options: nil)
        @api_client = ApiClient.new(
          api_key: api_key,
          vertexai: vertexai,
          project: project,
          location: location,
          http_options: http_options
        )
      end

      def models
        @models ||= Models.new(@api_client)
      end

      def chats
        @chats ||= Chats.new(self)
      end

      def files
        @files ||= Files.new(@api_client)
      end

      def tunings
        @tunings ||= Tunings.new(@api_client)
      end

      def caches
        @caches ||= Caches.new(@api_client)
      end

      def batches
        @batches ||= Batches.new(@api_client)
      end

      def operations
        @operations ||= Operations.new(@api_client)
      end

      def tokens
        @tokens ||= Tokens.new(@api_client)
      end

      def live
        @live ||= Live.new(@api_client)
      end