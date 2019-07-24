require "spec_helper"

RSpec.describe T::Mailer do
  describe ".configuration" do
    let(:config) { described_class.configuration }

    shared_examples "checking configuration" do |required_value|
      it "creates a new configuration #{required_value}" do
        expect(config).to_not be nil

        %w(
          aws_access_key_id
          aws_default_region
          aws_secret_access_key
          sparkpost_api_key
        ).each do |variable_name|
          value =
            case required_value
            when "with the ENV values", "with all values"
              variable_name
            when "with the AWS SES values"
              variable_name =~ /aws/ ? variable_name : ""
            when "with the SparkPost values"
              variable_name == "sparkpost_api_key" ? variable_name : ""
            else
              ""
            end

          expect(config.public_send(variable_name)).to eq(value)
        end
      end
    end

    context "when .configure is never called" do
      context "and enviroment variables do not exist" do
        it_behaves_like "checking configuration", "with defaults"
      end

      context "and enviroment variables exist" do
        before do
          %w(
            AWS_ACCESS_KEY_ID
            AWS_DEFAULT_REGION
            AWS_SECRET_ACCESS_KEY
            SPARKPOST_API_KEY
          ).each do |variable_name|
            allow(ENV).to receive(:[]).with(variable_name)
              .and_return(variable_name.downcase)
          end
        end

        it_behaves_like "checking configuration", "with the ENV values"
      end
    end

    context "when .configure is called" do
      context "and set just AWS SES" do
        before { configure_aws_ses }

        it_behaves_like "checking configuration", "with the AWS SES values"
      end

      context "and set just SparkPost" do
        before { configure_sparkpost }

        it_behaves_like "checking configuration", "with the SparkPost values"
      end

      context "and set all variables" do
        before { configure_all }

        it_behaves_like "checking configuration", "with all values"
      end
    end
  end
end
