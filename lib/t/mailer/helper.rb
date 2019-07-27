module T
  module Mailer
    module Helper
      # Check gem is installed or not. If not it will raise error.
      #
      # @param [String] a API's class name
      def check_api_defined(klass)
        unless T::Mailer.const_defined?(klass)
          fail Error::DeliverySystemNotDefined,
            "Please install #{using_gem(klass)} gem."
        end
      end

      # Check API credentials were given.
      # If one is missing or empty it will raise error.
      #
      # @param [List] comma separated values/symbols
      def check_settings(*required_values)
        has_all_settings =
          settings.values_at(*required_values).all? do |setting|
            setting && !setting.empty?
          end

        unless settings.is_a?(Hash) && has_all_settings
          fail Error::MissingCredentials,
            "Please provide all credential values. Required: #{required_values}"
        end
      end

      # Check the version of a gem.
      #
      # @param [String] the name of the gem
      # @param [String] the satisfied version of the gem
      #
      # @return [Boolean] true/false
      def check_version_of(gem_name, version)
        requirement     = Gem::Requirement.new(version)
        current_version = Gem.loaded_specs[gem_name].version

        requirement.satisfied_by?(current_version)
      end

      # How to gets the uparsed value of the mail message fields.
      #
      # @return [String] version dependent method call
      def field_value
        if check_version_of("mail", "> 2.7.0")
          %w(unparsed_value)
        elsif check_version_of("mail", "= 2.7.0")
          %w(instance_variable_get @unparsed_value)
        elsif check_version_of("mail", "< 2.7.0")
          %w(instance_variable_get @value)
        end
      end

      # Gets uparsed value of the mail message fields.
      #
      # @param [Mail::Field]
      #
      # @return [String/Hash] with the field unparsed value
      def get_value_from(message_field)
        return if message_field.nil?

        message_field.public_send(*field_value)
      end

      # Which gem using an API class.
      #
      # @param [String] class name
      #
      # @retrun [String] the gem name which should use
      def using_gem(klass)
        case klass
        when "Api::AwsSes"
          "aws-sdk-ses"
        when "Api::SparkPost::Transmissions"
          "simple_spark"
        else
          "unknown"
        end
      end
    end
  end
end
