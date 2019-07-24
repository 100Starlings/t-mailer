require "bundler/setup"
require "t/mailer"
require "mail"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    # Reset configuration
    T::Mailer.configuration = nil
  end
end

def configure_aws_ses
  T::Mailer.configure do |config|
    config.aws_access_key_id     = "aws_access_key_id"
    config.aws_default_region    = "aws_default_region"
    config.aws_secret_access_key = "aws_secret_access_key"
  end
end

def configure_sparkpost
  T::Mailer.configure do |config|
    config.sparkpost_api_key     = "sparkpost_api_key"
  end
end

def configure_all
  T::Mailer.configure do |config|
    config.aws_access_key_id     = "aws_access_key_id"
    config.aws_default_region    = "aws_default_region"
    config.aws_secret_access_key = "aws_secret_access_key"
    config.sparkpost_api_key     = "sparkpost_api_key"
  end
end
