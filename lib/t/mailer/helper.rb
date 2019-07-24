module T
  module Mailer
    module Helper
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
    end
  end
end
