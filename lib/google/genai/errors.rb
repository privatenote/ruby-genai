
# frozen_string_literal: true

module Google
  module Genai
    class Error < StandardError; end

    class APIError < Error
      attr_reader :code, :status, :details, :response

      def initialize(code, response_json, response)
        @response = response
        @details = response_json.is_a?(Array) && response_json.length == 1 ? response_json[0] : response_json
        @message = get_message(@details)
        @status = get_status(@details)
        @code = code || get_code(@details)

        super("#{@code} #{@status}. #{@details}")
      end

      private

      def get_status(details)
        details.is_a?(Hash) ? (details['status'] || details.dig('error', 'status')) : nil
      end

      def get_message(details)
        details.is_a?(Hash) ? (details['message'] || details.dig('error', 'message')) : nil
      end

      def get_code(details)
        details.is_a?(Hash) ? (details['code'] || details.dig('error', 'code')) : nil
      end
    end

    class ClientError < APIError; end
    class ServerError < APIError; end
    class UnknownFunctionCallArgumentError < ArgumentError; end
    class UnsupportedFunctionError < ArgumentError; end
    class FunctionInvocationError < StandardError; end
    class UnknownApiResponseError < StandardError; end
  end
end
