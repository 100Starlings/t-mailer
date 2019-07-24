module T
  module Mailer
    class Error < StandardError
      # Specific error class for errors if the given delivery system is not in the list
      class WrongDeliverySystem < Error; end

      # Specific error class for errors if the delivery system's API gem is not installed
      class DeliverySystemNotDefined < Error; end
    end
  end
end
