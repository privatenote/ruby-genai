# frozen_string_literal: true

require_relative 'types'

module Google
  module Genai
    class Operations
      def initialize(api_client)
        @api_client = api_client
      end

      def get(name:, config: nil)
        response = @api_client.get("v1beta/#{name}")
        Types::Operation.new(JSON.parse(response.body))
      end
    end
  end
end
