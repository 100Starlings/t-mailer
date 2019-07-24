require "spec_helper"

RSpec.describe T::Mailer::DeliveryMethod do
  describe "#initialize" do
    let(:default_options) do
      {
        aws_access_key_id:     "",
        aws_default_region:    "",
        aws_secret_access_key: "",
        sparkpost_api_key:     "",
      }
    end

    context "without options" do
      let(:delivery_method) { described_class.new }

      it "sets settings with default options" do
        expect(delivery_method.settings).to eq(default_options)
      end
    end

    context "with options" do
      let(:delivery_method) { described_class.new(options) }

      context "and add new option" do
        let(:options) { { key: "value" } }

        it "sets settings with the given options" do
          expect(delivery_method.settings).to eq(default_options.merge(options))
        end
      end

      context "and override an option" do
        let(:options) { { sparkpost_api_key: "value" } }

        it "sets settings with the given options" do
          expect(delivery_method.settings).to eq(default_options.merge(options))
        end

        it "overrides the sparkpost_api_key" do
          expect(delivery_method.settings[:sparkpost_api_key]).to eq("value")
        end
      end
    end
  end

  describe "#deliver!" do
    let(:delivery_method) { described_class.new }
    let(:message) do
      message = Mail.new(mail_options)
      message.delivery_handler = "delivery_handler"
      message
    end

    subject { delivery_method.deliver!(message) }

    context "when the delivery system is AWS SES" do
      let(:mail_options) do
        {
          delivery_system:        "ses",
          to:                     "to@example.com",
          tag:                    "tag_value",
          configuration_set_name: "test_events_tracking",
        }
      end

      it "calls the right delivery system with the right data" do
        expect(T::Mailer::DeliverySystem::AwsSes)
          .to receive_message_chain(:new, :deliver)
          .with(message)

        subject
      end
    end

    context "when the delivery system is SparPost" do
      let(:mail_options) do
        {
          delivery_system: "sparkpost",
          to:              "to@example.com",
          tag:             "tag_value",
          options:         {
            open_tracking:  true,
            click_tracking: false,
            transactional:  true,
          },
          metadata:        {
            website: "testwebsite",
          },
        }
      end

      it "calls the right delivery system with the right data" do
        expect(T::Mailer::DeliverySystem::SparkPost)
          .to receive_message_chain(:new, :deliver)
          .with(message)

        subject
      end
    end

    context "when the given delivery system is wrong" do
      let(:mail_options) { { delivery_system: "wrong", to: "to@example.com" } }

      it "raises error with message" do
        expect { subject }.to raise_error(T::Mailer::Error::WrongDeliverySystem,
          "The given delivery system is not supported.")
      end
    end

    context "when the given delivery system is missing" do
      let(:mail_options) { { to: "to@example.com" } }

      it "raises error with message" do
        expect { subject }.to raise_error(T::Mailer::Error::WrongDeliverySystem,
          "Delivery system is missing.")
      end
    end
  end
end
