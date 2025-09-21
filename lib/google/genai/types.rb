# frozen_string_literal: true
require "base64"

module Google
  module Genai
    module Types
      class Base
        def initialize(attributes = {})
          attributes.each do |key, value|
            setter = "#{key}="
            public_send(setter, value) if respond_to?(setter)
          end
        end
      end

      class Blob < Base
        attr_accessor :mime_type, :data

        def to_h
          { mimeType: mime_type, data: Base64.strict_encode64(data) }
        end
      end

      class FileData < Base
        attr_accessor :mime_type, :file_uri

        def to_h
          { mimeType: mime_type, fileUri: file_uri }
        end
      end

      class Part < Base
        attr_accessor :text, :inline_data, :file_data

        def to_h
          data = {}
          data[:text] = text if text
          data[:inlineData] = inline_data.to_h if inline_data
          data[:fileData] = file_data.to_h if file_data
          data
        end
      end

      class Content < Base
        attr_accessor :role, :parts

        def initialize(attributes = {})
          super
          self.parts = Array(self.parts).map { |p| p.is_a?(Part) ? p : Part.new(p) }
        end

        def to_h
          {
            role: role,
            parts: parts.map(&:to_h)
          }
        end
      end

      class GenerateContentResponse < Base
        attr_accessor :candidates

        def initialize(attributes = {})
          super
          self.candidates = Array(self.candidates).map { |c| c.is_a?(Candidate) ? c : Candidate.new(c) }
        end

        def text
          candidates&.first&.content&.parts&.map(&:text)&.join
        end
      end

      class Candidate < Base
        attr_accessor :content, :finish_reason, :safety_ratings

        def initialize(attributes = {})
          super
          self.content = Content.new(self.content) if self.content.is_a?(Hash)
        end
      end

      class File < Base
        attr_accessor :name, :display_name, :mime_type, :size_bytes, :create_time, :update_time, :expiration_time, :sha256_hash, :uri, :state, :error
      end

      class TuningJob < Base
        attr_accessor :name, :state, :create_time, :end_time, :tuned_model
      end

      class CachedContent < Base
        attr_accessor :name, :display_name, :model, :create_time, :update_time, :expire_time, :usage_metadata
      end

      class BatchJob < Base
        attr_accessor :name, :model, :state, :create_time, :end_time, :update_time, :error
      end

      class Operation < Base
        attr_accessor :name, :metadata, :done, :error, :response
      end
    end
  end
end
