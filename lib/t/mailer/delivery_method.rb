module T
  module Mailer
    class DeliveryMethod
      include Helper

      attr_reader :settings

      # Set settings with the required credentials for the API, but allow to
      # call the delivery method without it. In that case it will set that up
      # with the default. If credentials has been added then it will override
      # the default credentials.
      #
      # @param [Hash] options with the credentials
      def initialize(options = {})
        @settings = {
          aws_access_key_id:     T::Mailer.configuration.aws_access_key_id,
          aws_default_region:    T::Mailer.configuration.aws_default_region,
          aws_secret_access_key: T::Mailer.configuration.aws_secret_access_key,
          sparkpost_api_key:     T::Mailer.configuration.sparkpost_api_key,
        }.merge!(options)
      end

      # Check that the delivery system is provided. If delivery system is
      # missing it will raise error. If delivery system was provided then it
      # will call the given delivery system with the message. If the provided
      # delivery system does not exist the it will raise error.
      #
      # @param [Mail::Message] message what we would like to send
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
