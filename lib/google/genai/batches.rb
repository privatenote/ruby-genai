# frozen_string_literal: true

require_relative 'types'
require_relative 'pagers'

module Google
  module Genai
    class Batches
      def initialize(api_client)
        @api_client = api_client
      end

      def create(model:, src:, config: nil)
        raise "Batches is only supported for Vertex AI" unless @api_client.vertexai

        body = {
          model: model,
          inputConfig: {
            instancesFormat: src.is_a?(String) && src.start_with?('bq://') ? 'bigquery' : 'jsonl',
            gcsSource: { uris: [src] }
          }
        }
        # TODO: Add other config options

        response = @api_client.request(:post, "v1beta/batchPredictionJobs", body: body)
        Types::BatchJob.new(JSON.parse(response.body))
      end

      def get(name:, config: nil)
        raise "Batches is only supported for Vertex AI" unless @api_client.vertexai
        response = @api_client.get("v1beta/#{name}")
        Types::BatchJob.new(JSON.parse(response.body))
      end

      def list(config: nil)
        raise "Batches is only supported for Vertex AI" unless @api_client.vertexai
        
        list_request = ->(options) do
          path = "v1beta/batchPredictionJobs"
          params = {}
          params[:pageToken] = options[:page_token] if options&.key?(:page_token)
          params[:pageSize] = options[:page_size] if options&.key?(:page_size)
          path += "?#{URI.encode_www_form(params)}" unless params.empty?
          @api_client.get(path)
        end

        response = list_request.call(config)

        Pager.new(
          name: :batchPredictionJobs,
          request: list_request,
          response: response,
          config: config,
          item_class: Types::BatchJob
        )
      end

      def cancel(name:, config: nil)
        raise "Batches is only supported for Vertex AI" unless @api_client.vertexai
        @api_client.request(:post, "v1beta/#{name}:cancel", body: {})
        nil
      end

      def delete(name:, config: nil)
        raise "Batches is only supported for Vertex AI" unless @api_client.vertexai
        @api_client.delete("v1beta/#{name}")
        nil
      end
    end
  end
end
