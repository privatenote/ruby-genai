# Google GenAI Ruby SDK

> **Note:** This is an unofficial Ruby port of the official [Google Python SDK](https://github.com/googleapis/python-genai) for the Gemini API. This port was primarily developed with the assistance of the Gemini CLI.

Welcome to the Google GenAI Ruby SDK. This library allows you to integrate Google's generative AI models, including the Gemini family, into your Ruby applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'google-genai'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install google-genai

## Usage

Here's a quick example of how to upload an audio file and generate a summary.

```ruby
require 'google/genai'

# The client will automatically use the GOOGLE_API_KEY or GEMINI_API_KEY environment variable.
client = Google::Genai::Client.new

# Path to your local audio file.
audio_file_path = 'path/to/your/audio.mp4' # <--- CHANGE THIS

begin
  # Upload the file to the Gemini API.
  # If the automatically detected MIME type is incorrect (e.g., for an MP4 audio file),
  # you can override it like this:
  puts "Uploading file: #{audio_file_path}..."
  audio_file = client.files.upload(file: audio_file_path, config: { mime_type: 'audio/m4a' })
  puts "File uploaded successfully. URI: #{audio_file.uri}"

  # Ask the model to summarize the audio file.
  puts "Generating summary..."
  prompt = "Please provide a concise summary of this audio file."

  response = client.models.generate_content(
    model: 'gemini-2.5-flash',
    contents: [prompt, audio_file]
  )

  # Print the summary
  puts "\n--- Summary ---"
  puts response.text
  puts "---------------"

rescue Google::Genai::APIError => e
  puts "An API error occurred: #{e.message}"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/privatenote/ruby-genai.

## License

The gem is available as open source under the terms of the [Apache-2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
