# frozen_string_literal: true

require_relative 'types'

module Google
  module Genai
    class Tokens
      def initialize(api_client)
        @api_client = api_client
      end

      def create(config: nil)
        raise "Tokens is only supported for Gemini API" if @api_client.vertexai

        # This is a simplified port of the Python SDK's logic.
        # The full logic for field masks is complex and will be implemented later.
        
        body = {}
        body[:expireTime] = config[:expire_time] if config&.key?(:expire_time)
        body[:uses] = config[:uses] if config&.key?(:uses)

        if config&.key?(:live_connect_constraints)
          # This part of the conversion is complex and will require more detailed mapping.
          # For now, we'll pass a simplified version.
          body[:bidiGenerateContentSetup] = {
            setup: {
              model: config[:live_connect_constraints][:model]
            }
          }
          if config[:live_connect_constraints][:config]
            body[:bidiGenerateContentSetup][:setup][:generationConfig] = config[:live_connect_constraints][:config]
          end
        end

        response = @api_client.request(:post, "v1alpha/authTokens", body)
        Types::AuthToken.new(JSON.parse(response.body))
      end
    end
  end
end
