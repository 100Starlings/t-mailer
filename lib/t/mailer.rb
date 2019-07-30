require "t/mailer/helper"

require "t/mailer/delivery_method"
require "t/mailer/error"
require "t/mailer/version"

# If we use outside of Rails then do not load this code.
require "t/mailer/railtie" if defined?(Rails)

# If the required gem is not installed then do not load that API.
require "t/mailer/api/aws_ses" if Gem.loaded_specs.has_key?("aws-sdk-ses")
require "t/mailer/api/spark_post" if Gem.loaded_specs.has_key?("simple_spark")

require "t/mailer/delivery_system/aws_ses"
require "t/mailer/delivery_system/spark_post"

module T
  module Mailer
    class << self
      attr_accessor :configuration

      # Returns back with configuration or initialze it with default values.
      def configuration
        @configuration ||= Configuration.new
      end

      # Configure T::Mailer and set up required credentials if environment
      # variables does not exist.
      #
      # @example using Rails config/initializers/t-mailer.rb
      #
      #          T::Mailer.configure do |config|
      #            config.aws_access_key_id     = "aws_access_key_id"
      #            config.aws_default_region    = "aws_default_region"
      #            config.aws_secret_access_key = "aws_secret_access_key"
      #            config.sparkpost_api_key     = "sparkpost_api_key"
      #          end
      #
      def configure
        yield(configuration)
      end
    end

    class Configuration
      # Amazon AWS SES
      attr_accessor :aws_access_key_id
      attr_accessor :aws_default_region
      attr_accessor :aws_secret_access_key
      # SparkPost
      attr_accessor :sparkpost_api_key

      def initialize
        %w(
          AWS_ACCESS_KEY_ID
          AWS_DEFAULT_REGION
          AWS_SECRET_ACCESS_KEY
          SPARKPOST_API_KEY
        ).each do |variable_name|
          set_credential(variable_name)
        end
      end

      private

      # If environment variables exist then it can pick up and set up those
      # credentials automatically (no need config/initializers/t-mailer.rb file).
      # If environment variable does not exist then it will leave it blank.
      #
      # @param [String] variable_name the credential/API key variable name
      def set_credential(variable_name)
        if ENV[variable_name].nil?
          public_send("#{variable_name.downcase}=", "")
        else
          public_send("#{variable_name.downcase}=", ENV[variable_name])
        end
      end
    end
  end
end
