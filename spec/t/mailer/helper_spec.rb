require "spec_helper"

RSpec.describe T::Mailer::Helper do
  class TestClass
    include T::Mailer::Helper

    attr_reader :settings

    def initialize(options = {})
      @settings = options
    end
  end

  describe "#check_api_defined" do
    subject { TestClass.new.check_api_defined(klass) }

    context "when the API is not defined" do
      context "and given an unknown API" do
        let(:klass) { "Api::NotDefined" }

        it "raises error with message" do
          expect { subject }.to raise_error(
            T::Mailer::Error::DeliverySystemNotDefined,
            "Please install unknown gem."
          )
        end
      end

      context "and given a known API, but gem is not installed" do
        let(:klass) { "Api::AwsSes" }

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
    end

    context "when the API is not defined" do
      let(:klass) { "Api::AwsSes" }

      it "does not raise error" do
        expect(subject).to be nil
      end
    end
  end

  describe "#check_settings" do
    let(:required_values) { [:required_value] }

    subject { TestClass.new(options).check_settings(*required_values) }

    context "when settings are missing" do
      let(:options) { {} }

      it "raises error with message" do
        expect { subject }.to raise_error(
          T::Mailer::Error::MissingCredentials,
          "Please provide all credential values. Required: #{required_values}"
        )
      end
    end

    context "when settings is empty" do
      let(:options) { { required_value: "" } }

      it "raises error with message" do
        expect { subject }.to raise_error(
          T::Mailer::Error::MissingCredentials,
          "Please provide all credential values. Required: #{required_values}"
        )
      end
    end

    context "when settings exists and has value" do
      let(:options) { { required_value: "value" } }

      it "does not raise error" do
        expect(subject).to be nil
      end
    end
  end

  describe "#check_version_of" do
    before do
      allow(Gem.loaded_specs["mail"]).to receive(:version)
        .and_return(current_version)
    end

    subject { TestClass.new.check_version_of("mail", version) }

    context "when the gem version should greater than required" do
      let(:version) { "> 2.7.0" }

      context "and the current version less than or equal to the required" do
        let(:current_version) { Gem::Version.new("2.7.0") }

        it "returns with false" do
          expect(subject).to be false
        end
      end

      context "and the current version greater than the required" do
        let(:current_version) { Gem::Version.new("2.7.1") }

        it "returns with true" do
          expect(subject).to be true
        end
      end
    end

    context "when the mail gem version should equal to the required" do
      let(:version) { "= 2.7.0" }

      context "and the current version less than the required" do
        let(:current_version) { Gem::Version.new("2.6.9") }

        it "returns with false" do
          expect(subject).to be false
        end
      end

      context "and the current version greater than the required" do
        let(:current_version) { Gem::Version.new("2.7.1") }

        it "returns with false" do
          expect(subject).to be false
        end
      end

      context "and the current version equal to the required" do
        let(:current_version) { Gem::Version.new("2.7.0") }

        it "returns with true" do
          expect(subject).to be true
        end
      end
    end

    context "when the mail gem version should less than the required" do
      let(:version) { "< 2.7.0" }

      context "and the current version less than the required" do
        let(:current_version) { Gem::Version.new("2.6.9") }

        it "returns with true" do
          expect(subject).to be true
        end
      end

      context "and the current version greater than or equal to the required" do
        let(:current_version) { Gem::Version.new("2.7.0") }

        it "returns with false" do
          expect(subject).to be false
        end
      end
    end
  end

  describe "#field_value" do
    before do
      allow(Gem.loaded_specs["mail"]).to receive(:version).and_return(version)
    end

    subject { TestClass.new.field_value }

    context "when the mail gem version is > 2.7.0" do
      let(:version) { Gem::Version.new("2.7.1") }

      it "returns with the right method string" do
        expect(subject).to eq(["unparsed_value"])
      end
    end

    context "when the mail gem version is = 2.7.0" do
      let(:version) { Gem::Version.new("2.7.0") }

      it "returns with the right method string" do
        expect(subject).to eq(["instance_variable_get", "@unparsed_value"])
      end
    end

    context "when the mail gem version is < 2.7.0" do
      let(:version) { Gem::Version.new("2.6.9") }

      it "returns with the right method string" do
        expect(subject).to eq(["instance_variable_get", "@value"])
      end
    end
  end

  describe "#get_value_from" do
    let(:message) { Mail.new(mail_options) }

    subject { TestClass.new.get_value_from(message_field) }

    context "when field does not exist" do
      let(:mail_options) { {} }
      let(:message_field) { message["unknown"] }

      it "returns with nil" do
        expect(subject).to be nil
      end
    end

    context "when field exists" do
      let(:message_field) { message["test_field"] }

      context "and value is a string" do
        let(:mail_options) { { test_field: "test_field_value" } }

        it "returns with the value" do
          expect(subject).to eq("test_field_value")
        end
      end

      context "and value is a hash" do
        let(:mail_options) do
          { test_field: { test_field_key: "test_field_value" } }
        end

        it "returns with the value" do
          expect(subject).to eq({ "test_field_key" =>"test_field_value" })
        end
      end

      context "and value is a array" do
        let(:mail_options) do
          { test_field: [:test_field_value1, "test_field_value2"] }
        end

        it "returns with the value" do
          expect(subject).to eq([:test_field_value1, "test_field_value2"])
        end
      end
    end
  end

  describe "#using_gem" do
    subject { TestClass.new.using_gem(klass) }

    context "when klass is Api::AwsSes" do
      let(:klass) { "Api::AwsSes" }

      it "returns with the right gem name" do
        expect(subject).to eq("aws-sdk-ses")
      end
    end

    context "when klass is Api::SparkPost::Transmissions" do
      let(:klass) { "Api::SparkPost::Transmissions" }

      it "returns with the right gem name" do
        expect(subject).to eq("simple_spark")
      end
    end

    context "when klass is not listed" do
      let(:klass) { "something::different" }

      it "returns with the unknown word" do
        expect(subject).to eq("unknown")
      end
    end
  end
end
