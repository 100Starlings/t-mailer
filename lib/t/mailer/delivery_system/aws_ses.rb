module T
  module Mailer
    module DeliverySystem
      class AwsSes
        include Helper

        attr_reader :settings

        def initialize(options = {})
          @settings = options
        end

        def deliver(message)
          check_api_defined("Api::AwsSes")

          options = generate_options(message)

          response = Api::AwsSes.new(settings).send_raw_email(options)
          message.message_id = response && response.message_id

          message
        end

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
