require "spec_helper"

RSpec.describe T::Mailer::Error do
  describe "WrongDeliverySystem" do
    it "raises error with message" do
      begin
        raise described_class::WrongDeliverySystem, "Error message"
      rescue described_class::WrongDeliverySystem => error
        expect(error.message).to eq("Error message")
      end
    end
  end

  describe "DeliverySystemNotDefined" do
    it "raises error with message" do
      begin
        raise described_class::DeliverySystemNotDefined, "Error message"
      rescue described_class::DeliverySystemNotDefined => error
        expect(error.message).to eq("Error message")
      end
    end
  end

  describe "MissingCredentials" do
    it "raises error with message" do
      begin
        raise described_class::MissingCredentials, "Error message"
      rescue described_class::MissingCredentials => error
        expect(error.message).to eq("Error message")
      end
    end
  end
end
