require "spec_helper"

RSpec.describe T::Mailer::Api::SparkPost::Transmissions do
  let(:options) do
    {
      sparkpost_api_key: "sparkpost_api_key",
    }
  end

  describe "#initialize" do
    context "without options" do
      subject { described_class.new }

      it "raises error" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context "with options" do
      let(:required_values) { [:sparkpost_api_key] }

      subject { described_class.new(options) }

      context "and the credential is missing" do
        let(:options) { {} }

        it "raises error with message" do
          expect { subject }.to raise_error(
            T::Mailer::Error::MissingCredentials,
            "Please provide all credential values. Required: #{required_values}"
          )
        end
      end

      context "and the credential is empty" do
        let(:options) do
          {
            sparkpost_api_key: "",
          }
        end

        it "raises error with message" do
          expect { subject }.to raise_error(
            T::Mailer::Error::MissingCredentials,
            "Please provide all credential values. Required: #{required_values}"
          )
        end
      end

      context "and with the right credentials" do
        it "sets settings with the given options" do
          expect(subject.settings).to eq(options)
        end
      end
    end
  end

  describe "#client" do
    subject { described_class.new(options).client }

    it "creates an SimpleSpark Client" do
      expect(SimpleSpark::Client).to receive(:new)
        .with(api_key: options[:sparkpost_api_key])

      subject
    end
  end

  describe "#create" do
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
    let(:message) do
      message = Mail.new(mail_options)
      message.delivery_handler = "delivery_handler"
      message
    end
    let(:attrs) do
      {
        options:     {
          open_tracking:  true,
          click_tracking: false,
          transactional:  true,
        },
        campaign_id: "tag_value",
        content:     {
          email_rfc822: message.to_s,
        },
        metadata:    {
          website: "testwebsite",
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
    let(:message_id) { "11668787484950529" }

    subject { described_class.new(options).create(attrs) }

    before do
      stub_request(:post, /sparkpost.com/).to_return(
        status: 200,
        body: File.read("#{Dir.pwd}/spec/fixtures/spark_post_response.json"),
      )
    end

    it "returns with message_id" do
      expect(subject.dig("id")).to eq(message_id)
    end
  end
end
