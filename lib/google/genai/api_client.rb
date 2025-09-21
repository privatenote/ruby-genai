# frozen_string_literal: true

require "faraday"
require "faraday/retry"
require "googleauth"
require "json"
require "mimemagic"
require_relative "errors"

module Google
  module Genai
    class ApiClient
      attr_reader :api_key, :vertexai

      def initialize(api_key: nil, vertexai: nil, project: nil, location: nil, http_options: nil)
        @api_key = api_key
        @vertexai = vertexai
        @http_options = http_options || {}

        base_url = if @vertexai
                     # TODO: Handle global location
                     "https://#{location}-aiplatform.googleapis.com/"
                   else
                     "https://generativelanguage.googleapis.com/"
                   end

        @connection = Faraday.new(url: base_url) do |faraday|
          faraday.request :retry
          faraday.headers['Content-Type'] = 'application/json'
          if @api_key
            faraday.headers['x-goog-api-key'] = @api_key
          elsif @vertexai
            scopes = ['https://www.googleapis.com/auth/cloud-platform']
            authorizer = Google::Auth.get_application_default(scopes)
            faraday.request :authorization, 'Bearer', -> { authorizer.fetch_access_token!['access_token'] }
          end
        end
      end

      def upload_file(file_path, file_size, mime_type, display_name: nil)
        # 1. Start resumable upload
        start_upload_headers = {
          "X-Goog-Upload-Protocol" => "resumable",
          "X-Goog-Upload-Command" => "start",
          "X-Goog-Upload-Header-Content-Length" => file_size.to_s,
          "X-Goog-Upload-Header-Content-Type" => mime_type,
          "Content-Type" => "application/json"
        }
        start_response = @connection.post("upload/v1beta/files") do |req|
          req.headers.merge!(start_upload_headers)
          req.body = { file: { display_name: display_name } }.to_json
        end

        handle_response(start_response)

        upload_url = start_response.headers["x-goog-upload-url"]

        # 2. Upload file content
        File.open(file_path, "rb") do |file|
          upload_connection = Faraday.new(url: upload_url)
          upload_response = upload_connection.post do |req|
            req.headers.merge!({
              "X-Goog-Upload-Offset" => "0",
              "X-Goog-Upload-Command" => "upload, finalize",
              "Content-Length" => file_size.to_s,
              "Content-Type" => mime_type
            })
            req.body = file.read
          end
          
          handle_response(upload_response)
          return JSON.parse(upload_response.body)
        end
      end

      def request(http_method, path, body: nil)
        response = @connection.send(http_method, path) do |req|
          req.body = body.to_json if body
        end
        handle_response(response)
      end

      def get(path)
        request(:get, path)
      end

      def delete(path)
        request(:delete, path)
      end

      private

      def handle_response(response)
        return response if response.success?

        begin
          response_json = JSON.parse(response.body)
        rescue JSON::ParserError
          response_json = {
            'message' => response.body,
            'status' => response.reason_phrase
          }
        end

        status_code = response.status
        if (400...500).cover?(status_code)
          raise ClientError.new(status_code, response_json, response)
        elsif (500...600).cover?(status_code)
          raise ServerError.new(status_code, response_json, response)
        else
          raise APIError.new(status_code, response_json, response)
        end
      end
    end
  end
end
