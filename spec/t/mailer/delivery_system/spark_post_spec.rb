require "spec_helper"

RSpec.describe T::Mailer::DeliverySystem::SparkPost do
  let(:options) do
    {
      sparkpost_api_key: "sparkpost_api_key",
    }
  end
  let(:message) do
    message = Mail.new(mail_options)
    message.delivery_handler = "delivery_handler"
    message
  end
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
          "Please install simple_spark gem."
        )
      end
    end

    context "and the API is defined" do
      let(:api_options) { described_class.new.generate_options(message) }
      let(:respose) do
        {
          "total_rejected_recipients" => 0,
          "total_accepted_recipients" => 1,
          "id"                        => "message_id",
        }
      end

      it "calls the right api with the right data" do
        expect(T::Mailer::Api::SparkPost::Transmissions)
          .to receive_message_chain(:new, :create)
          .with(api_options)

        subject
      end

      context "and checks returned values" do
        before do
          allow(T::Mailer::Api::SparkPost::Transmissions)
            .to receive_message_chain(:new, :create)
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
        options:     {
          "open_tracking"  => true,
          "click_tracking" => false,
          "transactional"  => true,
        },
        campaign_id: "tag_value",
        content:     {
          email_rfc822: message.to_s,
        },
        metadata:    {
          "website" => "testwebsite",
        },
        recipients:  [
          {
            address: {
              email: "to@example.com",
            },
            tags:    [
              "tag_value",
            ],
          },
        ],
      }
    end

    subject { described_class.new.generate_options(message) }

    it "returns with the needed options" do
      expect(subject).to eq(api_options)
    end
  end

  describe "#generate_recipients" do
    let(:recipients) do
      [
        {
          address: {
            email: "to@example.com",
          },
          tags:    [
            "tag_value",
          ],
        },
      ]
    end

    subject { described_class.new.generate_recipients(message) }

    it "returns with the needed options" do
      expect(subject).to eq(recipients)
    end
  end
end
