# If the use outside of Rails then do not load this code.
return unless defined?(Rails)

module T
  module Mailer
    class Railtie < Rails::Railtie
      initializer "t-mailer.add_delivery_method" do
        ActiveSupport.on_load :action_mailer do
          ActionMailer::Base.add_delivery_method :t_mailer, T::Mailer::DeliveryMethod
        end
      end
    end
  end
end
