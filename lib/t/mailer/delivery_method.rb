module T
  module Mailer
    class DeliveryMethod
      include Helper

      attr_reader :settings

      def initialize(options = {})
        @settings = {
          aws_access_key_id:     T::Mailer.configuration.aws_access_key_id,
          aws_default_region:    T::Mailer.configuration.aws_default_region,
          aws_secret_access_key: T::Mailer.configuration.aws_secret_access_key,
          sparkpost_api_key:     T::Mailer.configuration.sparkpost_api_key,
        }.merge!(options)
      end

      def deliver!(message)
        delivery_system = get_value_from(message["delivery_system"])

        if delivery_system.nil?
          fail Error::WrongDeliverySystem, "Delivery system is missing."
        end

        case delivery_system
        when "ses"
          deliver_with_aws_ses(message)
        when "sparkpost"
          deliver_with_sparkpost(message)
        else
          fail Error::WrongDeliverySystem,
            "The given delivery system is not supported."
        end
      end

      private

      def deliver_with_aws_ses(message)
        check_delivery_system_defined("Api::AwsSes")

        options = {}
        options[:raw_message] = { data: message.to_s }
        options[:tags] = [
          {
            name:  message.delivery_handler.to_s,
            value: get_value_from(message["tag"]),
          },
        ]
        options[:configuration_set_name] =
          get_value_from(message["configuration_set_name"])

        response = Api::AwsSes.new(settings).send_raw_email(options)
        message.message_id = response && response.message_id

        message
      end

      def deliver_with_sparkpost(message)
        check_delivery_system_defined("Api::SparkPost::Transmissions")

        recipients = message.to.map do |to|
          {
            address: {
              email: to,
            },
            tags:    [
              get_value_from(message["tag"]),
            ],
          }
        end

        options = {
          options:     get_value_from(message["options"]),
          campaign_id: get_value_from(message["tag"]),
          content:     {
            email_rfc822: message.to_s,
          },
          metadata:    get_value_from(message["metadata"]),
          recipients:  recipients,
        }

        response = Api::SparkPost::Transmissions.new(settings).create(options)
        message.message_id = response && response.dig("id")

        message
      end
    end
  end
end
