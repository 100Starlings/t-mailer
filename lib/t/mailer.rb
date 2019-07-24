require "t/mailer/helper"

require "t/mailer/delivery_method"
require "t/mailer/error"
require "t/mailer/railtie"
require "t/mailer/version"

require "t/mailer/api/aws_ses"
require "t/mailer/api/spark_post"

module T
  module Mailer
    class << self
      attr_accessor :configuration

      def configuration
        @configuration ||= Configuration.new
      end

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
