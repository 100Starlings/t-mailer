module T
  module Mailer
    module DeliverySystem
      class SparkPost
        include Helper

        attr_reader :settings

        # Set settings with the required credentials for the API, but allow to
        # call this delivery system without it.
        #
        # @param [Hash] with the credentials
        def initialize(options = {})
          @settings = options
        end

        # Check that the API is loaded. If API is missing it will raise error.
        # If API exists then it will call the API with the generated options
        # from the given mail message.
        #
        # @param [Mail::Message] message what we would like to send
        #
        # @return [Mail::Message] message with the changed message_id
        def deliver(message)
          check_api_defined("Api::SparkPost::Transmissions")

          options = generate_options(message)

          response = Api::SparkPost::Transmissions.new(settings).create(options)
          message.message_id = response && response.dig("id")

          message
        end

        # Generate the required hash what it will send via API.
        #
        # @param [Mail::Message] message what we would like to send
        #
        # @return [Hash] options for the API
        def generate_options(message)
          {
            options:     get_value_from(message["options"]),
            campaign_id: get_value_from(message["tag"]),
            content:     {
              email_rfc822: message.to_s,
            },
            metadata:    get_value_from(message["metadata"]),
            recipients:  generate_recipients(message),
          }
        end

        # Generate recipients.
        #
        # @param [Mail::Message] message what we would like to send
        #
        # @return [Array] with the recipients and tags
        def generate_recipients(message)
          message.to.map do |to|
            {
              address: {
                email: to,
              },
              tags:    [
                get_value_from(message["tag"]),
              ],
            }
          end
        end
      end
    end
  end
end
