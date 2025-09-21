# frozen_string_literal: true

require_relative 'types'
require_relative 'pagers'

module Google
  module Genai
    class Tunings
      def initialize(api_client)
        @api_client = api_client
      end

      def create(base_model:, training_dataset:, config: nil)
        raise "Tuning is only supported for Vertex AI" unless @api_client.vertexai

        body = {
          baseModel: base_model,
          supervisedTuningSpec: {
            trainingDatasetUri: training_dataset[:gcs_uri] || training_dataset[:vertex_dataset_resource]
          }
        }
        # TODO: Add other config options

        response = @api_client.request(:post, "v1beta/tuningJobs", body: body)
        Types::TuningJob.new(JSON.parse(response.body))
      end

      def get(name:, config: nil)
        raise "Tuning is only supported for Vertex AI" unless @api_client.vertexai
        response = @api_client.get("v1beta/#{name}")
        Types::TuningJob.new(JSON.parse(response.body))
      end

      def list(config: nil)
        raise "Tuning is only supported for Vertex AI" unless @api_client.vertexai
        
        list_request = ->(options) do
          path = "v1beta/tuningJobs"
          params = {}
          params[:pageToken] = options[:page_token] if options&.key?(:page_token)
          params[:pageSize] = options[:page_size] if options&.key?(:page_size)
          path += "?#{URI.encode_www_form(params)}" unless params.empty?
          @api_client.get(path)
        end

        response = list_request.call(config)

        Pager.new(
          name: :tuningJobs,
          request: list_request,
          response: response,
          config: config,
          item_class: Types::TuningJob
        )
      end

      def cancel(name:, config: nil)
        raise "Tuning is only supported for Vertex AI" unless @api_client.vertexai
        @api_client.request(:post, "v1beta/#{name}:cancel", body: {})
        nil
      end
    end
  end
end
