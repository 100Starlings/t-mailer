module T
  module Mailer
    module DeliverySystem
      class AwsSes
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
        # @return [Mail::Message] message with the changed the message_id
        def deliver(message)
          check_api_defined("Api::AwsSes")

          options = generate_options(message)

          response = Api::AwsSes.new(settings).send_raw_email(options)
          message.message_id = response && response.message_id

          message
        end

        # Generate the required hash what it will send via API.
        #
        # @param [Mail::Message] message what we would like to send
        #
        # @return [Hash] options for the API
        def generate_options(message)
          {
            raw_message:            {
              data: message.to_s,
            },
            tags:                   [
              {
                name:  message.delivery_handler.to_s,
                value: get_value_from(message["tag"]),
              },
            ],
            configuration_set_name: get_value_from(message["configuration_set_name"]),
          }
        end
      end
    end
  end
end
