# frozen_string_literal: true

module Google
  module Genai
    class Chats
      def initialize(client)
        @client = client
      end

      def create(model:, history: [], config: nil)
        Chat.new(client: @client, model: model, history: history, config: config)
      end
    end

    class Chat
      attr_reader :history

      def initialize(client:, model:, history: [], config: nil)
        @client = client
        @model = model
        @history = history
        @config = config
      end

      def send_message(message)
        @history << { role: 'user', parts: [{ text: message }] }
        response = @client.models.generate_content(
          model: @model,
          contents: @history,
          config: @config
        )
        @history << response.candidates.first.content.to_h
        response
      end
    end
  end
end
