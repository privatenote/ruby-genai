# frozen_string_literal: true

require_relative 'types'
require_relative 'pagers'

module Google
  module Genai
    class Models
      def initialize(api_client)
        @api_client = api_client
      end

      def generate_content(model:, contents:, config: nil)
        path = "v1beta/models/#{model}:generateContent"
        body = {
          contents: normalize_contents(contents)
        }
        body[:generationConfig] = config if config

        response = @api_client.request(:post, path, body: body)
        Types::GenerateContentResponse.new(JSON.parse(response.body))
      end

      def list(config: nil)
        query_base = config&.dig(:query_base) != false
        
        list_request = ->(options) do
          path = "v1beta/#{query_base ? 'models' : 'tunedModels'}"
          params = {}
          params[:pageToken] = options[:page_token] if options&.key?(:page_token)
          params[:pageSize] = options[:page_size] if options&.key?(:page_size)
          path += "?#{URI.encode_www_form(params)}" unless params.empty?
          @api_client.get(path)
        end

        response = list_request.call(config)

        Pager.new(
          name: query_base ? :models : :tunedModels,
          request: list_request,
          response: response,
          config: config,
          item_class: Types::Model
        )
      end

      private

      def normalize_contents(contents)
        contents = [contents] unless contents.is_a?(Array)

        contents.map do |item|
          case item
          when String
            { role: 'user', parts: [{ text: item }] }
          when Hash
            item # Assumes it's already in the correct format
          when Types::Content
            item.to_h
          else
            raise ArgumentError, "Unsupported content type: #{item.class}"
          end
        end
      end
    end
  end
end
