require "spec_helper"

RSpec.describe T::Mailer::DeliverySystem::AwsSes do
  let(:options) do
    {
      aws_access_key_id:     "aws_access_key_id",
      aws_default_region:    "aws_default_region",
      aws_secret_access_key: "aws_secret_access_key",
    }
  end
  let(:message) do
    message = Mail.new(mail_options)
    message.delivery_handler = "delivery_handler"
    message
  end
  let(:mail_options) do
    {
      delivery_system:        "ses",
      to:                     "to@example.com",
      tag:                    "tag_value",
      configuration_set_name: "test_events_tracking",
    }
  end

  describe "#initialize" do
    context "without options" do
      subject { described_class.new }

      it "sets settings with empty hash" do
        expect(subject.settings).to eq({})
      end
    end

    context "with options" do
      subject { described_class.new(options) }

      context "and with the right credentials" do
        it "sets settings with the given options" do
          expect(subject.settings).to eq(options)
        end
      end
    end
  end

  describe "#deliver" do
    subject { described_class.new(options).deliver(message) }

    context "and the API is not defined" do
      before do
        allow(T::Mailer).to receive(:const_defined?).and_return(false)
      end

      it "raises error with message" do
        expect { subject }.to raise_error(
          T::Mailer::Error::DeliverySystemNotDefined,
          "Please install aws-sdk-ses gem."
        )
      end
    end

    context "and the API is defined" do
      let(:api_options) { described_class.new.generate_options(message) }
      let(:respose)     { OpenStruct.new(message_id: "message_id") }

      it "calls the right api with the right data" do
        expect(T::Mailer::Api::AwsSes)
          .to receive_message_chain(:new, :send_raw_email)
          .with(api_options)

        subject
      end

      context "and checks returned values" do
        before do
          allow(T::Mailer::Api::AwsSes)
            .to receive_message_chain(:new, :send_raw_email)
            .and_return(respose)
        end

        it "returns back with the right message id" do
          expect(subject.message_id).to eq("message_id")
        end
      end
    end
  end

  describe "#generate_options" do
    let(:api_options) do
      {
        raw_message:            {
          data: message.to_s,
        },
        tags:                   [
          {
            name:  "delivery_handler",
            value: "tag_value",
          },
        ],
        configuration_set_name: "test_events_tracking",
      }
    end

    subject { described_class.new.generate_options(message) }

    it "returns with the needed options" do
      expect(subject).to eq(api_options)
    end
  end
end
