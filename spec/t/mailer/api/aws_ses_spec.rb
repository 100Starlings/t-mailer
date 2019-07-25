require "spec_helper"

RSpec.describe T::Mailer::Api::AwsSes do
  let(:options) do
    {
      aws_access_key_id:     "aws_access_key_id",
      aws_default_region:    "aws_default_region",
      aws_secret_access_key: "aws_secret_access_key",
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
      let(:required_values) do
        [:aws_access_key_id, :aws_default_region, :aws_secret_access_key]
      end

      subject { described_class.new(options) }

      context "and a credential is missing" do
        let(:options) do
          {
            aws_access_key_id:     "aws_access_key_id",
            aws_default_region:    "aws_default_region",
          }
        end

        it "raises error with message" do
          expect { subject }.to raise_error(
            T::Mailer::Error::MissingCredentials,
            "Please provide all credential values. Required: #{required_values}"
          )
        end
      end

      context "and a credential is empty" do
        let(:options) do
          {
            aws_access_key_id:     "aws_access_key_id",
            aws_default_region:    "aws_default_region",
            aws_secret_access_key: "",
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

    it "creates an AWS SES Client" do
      expect(Aws::Credentials).to receive(:new)
        .with(options[:aws_access_key_id], options[:aws_secret_access_key])
        .and_return("credentials")

      expect(Aws::SES::Client).to receive(:new)
        .with(credentials: "credentials", region: options[:aws_default_region])

      subject
    end
  end

  describe "#send_raw_email" do
    let(:mail_options) do
      {
        delivery_system:        "ses",
        to:                     "to@example.com",
        tag:                    "tag_value",
        configuration_set_name: "test_events_tracking",
      }
    end
    let(:message) do
      message = Mail.new(mail_options)
      message.delivery_handler = "delivery_handler"
      message
    end
    let(:params) do
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
    let(:message_id) do
      "000001271b15238a-fd3ae762-2563-11df-8cd4-6d4e828a9ae8-000000"
    end

    subject { described_class.new(options).send_raw_email(params) }

    before do
      stub_request(:post, /amazonaws.com/).to_return(
        status: 200,
        body: File.read("#{Dir.pwd}/spec/fixtures/aws_ses_response.xml"),
      )
    end

    it "returns with message_id" do
      expect(subject.message_id).to eq(message_id)
    end
  end
end
