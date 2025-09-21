# frozen_string_literal: true

require_relative 'types'
require_relative 'pagers'

module Google
  module Genai
    class Caches
      def initialize(api_client)
        @api_client = api_client
      end

      def create(model:, config:)
        response = @api_client.request(:post, "v1beta/cachedContents", { model: model }.merge(config))
        Types::CachedContent.new(JSON.parse(response.body))
      end

      def get(name:, config: nil)
        response = @api_client.get("v1beta/#{name}")
        Types::CachedContent.new(JSON.parse(response.body))
      end

      def list(config: nil)
        list_request = ->(options) do
          path = "v1beta/cachedContents"
          params = {}
          params[:pageToken] = options[:page_token] if options&.key?(:page_token)
          params[:pageSize] = options[:page_size] if options&.key?(:page_size)
          path += "?#{URI.encode_www_form(params)}" unless params.empty?
          @api_client.get(path)
        end

        response = list_request.call(config)

        Pager.new(
          name: :cachedContents,
          request: list_request,
          response: response,
          config: config,
          item_class: Types::CachedContent
        )
      end

      def update(name:, config:)
        response = @api_client.request(:patch, "v1beta/#{name}", config)
        Types::CachedContent.new(JSON.parse(response.body))
      end

      def delete(name:, config: nil)
        @api_client.delete("v1beta/#{name}")
        nil
      end
    end
  end
end
