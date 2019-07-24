module T
  module Mailer
    module DeliverySystem
      class SparkPost
        include Helper

        attr_reader :settings

        def initialize(options)
          @settings = options
        end

        def deliver(message)
          check_delivery_system_defined("Api::SparkPost::Transmissions")

          options = generate_options(message)

          response = Api::SparkPost::Transmissions.new(settings).create(options)
          message.message_id = response && response.dig("id")

          message
        end

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
