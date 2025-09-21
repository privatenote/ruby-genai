# frozen_string_literal: true

require 'websocket-client-simple'
require 'json'

module Google
  module Genai
    class LiveMusic
      def initialize(api_client)
        @api_client = api_client
      end

      def connect(model:)
        raise "Live Music API is not supported for Vertex AI yet" if @api_client.vertexai

        base_url = "wss://generativelanguage.googleapis.com"
        version = @api_client.instance_variable_get(:@http_options)&.[](:api_version) || 'v1beta'
        api_key = @api_client.api_key
        
        uri = "#{base_url}/ws/google.ai.generativelanguage.#{version}.GenerativeService.BidiGenerateMusic?key=#{api_key}"
        
        ws = WebSocket::Client::Simple.connect(uri)
        
        session = MusicSession.new(ws)
        
        setup_message = {
          setup: {
            model: "models/#{model}"
          }
        }
        ws.send(setup_message.to_json)
        
        sleep 0.1 until ws.open?
        
        yield session
      ensure
        ws.close if ws&.open?
      end
    end

    class MusicSession
      def initialize(websocket)
        @ws = websocket
        @message_queue = Queue.new
        
        @ws.on :message do |msg|
          @message_queue.push(JSON.parse(msg.data))
        end

        @ws.on :error do |err|
          puts "WebSocket Error: #{err.message}"
        end
      end

      def set_weighted_prompts(prompts:)
        message = {
          clientContent: {
            weightedPrompts: prompts.map(&:to_h)
          }
        }
        @ws.send(message.to_json)
      end

      def set_music_generation_config(config:)
        @ws.send({ musicGenerationConfig: config }.to_json)
      end

      def play
        _send_control_signal('PLAY')
      end

      def pause
        _send_control_signal('PAUSE')
      end

      def stop
        _send_control_signal('STOP')
      end

      def reset_context
        _send_control_signal('RESET_CONTEXT')
      end

      def receive
        @message_queue.pop
      end

      private

      def _send_control_signal(control_signal)
        message = {
          playbackControl: control_signal
        }
        @ws.send(message.to_json)
      end
    end
  end
end
