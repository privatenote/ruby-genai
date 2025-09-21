# frozen_string_literal: true

require_relative 'pagers'

module Google
  module Genai
    class Files
      def initialize(api_client)
        @api_client = api_client
      end

      def upload(file:, config: nil)
        file_path = file.is_a?(String) ? file : file.path
        raise ArgumentError, "File not found: #{file_path}" unless File.exist?(file_path)

        config ||= {}
        mime_type = config[:mime_type] || MimeMagic.by_path(file_path)&.type
        raise ArgumentError, "Could not determine MIME type for file: #{file_path}" unless mime_type

        display_name = config[:display_name] || File.basename(file_path)
        file_size = File.size(file_path)

        response_data = @api_client.upload_file(file_path, file_size, mime_type, display_name: display_name)
        Types::File.new(response_data['file'])
      end

      def get(name:, config: nil)
        response = @api_client.get("v1beta/files/#{name}")
        Types::File.new(JSON.parse(response.body))
      end

      def delete(name:, config: nil)
        @api_client.delete("v1beta/files/#{name}")
        nil
      end

      def list(config: nil)
        list_request = ->(options) do
          path = "v1beta/files"
          params = {}
          params[:pageToken] = options[:page_token] if options&.key?(:page_token)
          params[:pageSize] = options[:page_size] if options&.key?(:page_size)
          path += "?#{URI.encode_www_form(params)}" unless params.empty?
          @api_client.get(path)
        end

        response = list_request.call(config)

        Pager.new(
          name: :files,
          request: list_request,
          response: response,
          config: config,
          item_class: Types::File
        )
      end

      def download(file:, config: nil)
        # TODO: Implement file download logic
      end
    end
  end
end
