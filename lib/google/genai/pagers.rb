# frozen_string_literal: true

module Google
  module Genai
    class Pager
      include Enumerable

      attr_reader :name, :page_size, :config, :sdk_http_response

      def initialize(name:, request:, response:, config:, item_class:)
        @item_class = item_class
        _init_page(name: name, request: request, response: response, config: config)
      end

      def each(&block)
        loop do
          @page.each(&block)
          break unless next_page_token
          next_page
        end
      end

      def page
        @page
      end

      def next_page
        raise IndexError, 'No more pages to fetch.' unless next_page_token

        response = @request.call(config: @config)
        _init_page(name: @name, request: @request, response: response, config: @config)
        @page
      end

      private

      def _init_page(name:, request:, response:, config:)
        @name = name
        @request = request
        
        response_body = JSON.parse(response.body)
        @page = (response_body[name.to_s] || []).map { |item_data| @item_class.new(item_data) }
        
        @sdk_http_response = response

        @config = config ? config.dup : {}
        @config[:page_token] = response_body['nextPageToken']
        
        @page_size = @config[:page_size] || @page.length
      end

      def next_page_token
        @config[:page_token]
      end
    end
  end
end
