# frozen_string_literal: true

require 'websocket-client-simple'
require 'json'
require_relative 'live_music'

module Google
  module Genai
    class Live
      def initialize(api_client)
        @api_client = api_client
      end

      def music
        @music ||= LiveMusic.new(@api_client)
      end

      def connect(model:, config: nil)
        raise "Live API is not supported for Vertex AI yet" if @api_client.vertexai

        base_url = "wss://generativelanguage.googleapis.com"
        version = @api_client.instance_variable_get(:@http_options)&.[](:api_version) || 'v1beta'
        api_key = @api_client.api_key
        
        uri = "#{base_url}/ws/google.ai.generativelanguage.#{version}.GenerativeService.BidiGenerateContent?key=#{api_key}"
        
        ws = WebSocket::Client::Simple.connect(uri)
        
        session = Session.new(ws)
        
        setup_message = {
          setup: {
            model: "models/#{model}",
            generationConfig: config
          }
        }
        ws.send(setup_message.to_json)
        
        # Block until the connection is open and initial setup is confirmed.
        # This is a simplified way to handle the async nature of websockets in a sync method.
        # A more robust solution would involve a proper event loop.
        sleep 0.1 until ws.open?
        
        yield session
      ensure
        ws.close if ws&.open?
      end
    end

    class Session
      def initialize(websocket)
        @ws = websocket
        @message_queue = Queue.new
        
        @ws.on :message do |msg|
          @message_queue.push(JSON.parse(msg.data))
        end

        @ws.on :error do |err|
          # For now, just print the error. A more robust error handling can be added.
          puts "WebSocket Error: #{err.message}"
        end
      end

      def send_client_content(turns:, turn_complete: true)
        message = {
          clientContent: {
            turns: turns,
            turnComplete: turn_complete
          }
        }
        @ws.send(message.to_json)
      end

      def receive
        @message_queue.pop
      end
    end
  end
end
