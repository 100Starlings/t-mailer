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
          DeliverySystem::AwsSes.new(settings).deliver(message)
        when "sparkpost"
          DeliverySystem::SparkPost.new(settings).deliver(message)
        else
          fail Error::WrongDeliverySystem,
            "The given delivery system is not supported."
        end
      end
    end
  end
end
