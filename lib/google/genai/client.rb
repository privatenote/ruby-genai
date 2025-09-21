# frozen_string_literal: true

# Zeitwerk will autoload all the required files.

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
    end
  end
end