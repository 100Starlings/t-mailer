# T-mailer

[![Build Status](https://travis-ci.com/100Starlings/t-mailer.svg?branch=master)](https://travis-ci.com/100Starlings/t-mailer)
[![Gem Version](https://badge.fury.io/rb/t-mailer.svg)](https://badge.fury.io/rb/t-mailer)

**T-mailer** helps you to use **ActionMailer** with different providers' **API**. It sends emails using **raw/rfc822** message type. Which means it converts the mail object to string and sends it completely. There is no any intermediate changes, so what you send is what you get. It supports more APIs (see below) and you can decide which one would like to use. It allows you to send different emails with different APIs. It can help to move between providers, load balacing or cost management.

## Supported APIs

- Amazon AWS SES
- SparkPost

## Installation

Add this line to your application's Gemfile:

```ruby
gem "t-mailer"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install t-mailer

### Dependency Installation

The T-mailer gem is needed other gem(s) to install, depends on which API would like to use.

#### Amazon AWS SES

Gemfile:

```ruby
gem "aws-sdk-ses"
```

Or

    $ gem install aws-sdk-ses

#### SparkPost

Gemfile:

```ruby
gem "simple_spark"
```

Or

    $ gem install simple_spark

## Rails Setup

First, add the required gems to your Gemfile and run the `bundle` command to install it.

After that, set the delivery method in `config/environments/production.rb`.

```ruby
config.action_mailer.delivery_method = :t_mailer
```

By default, the gem will look for your API keys in your environment:

#### Amazon AWS SES

```ruby
AWS_ACCESS_KEY_ID
AWS_DEFAULT_REGION
AWS_SECRET_ACCESS_KEY
```

#### SparkPost

```ruby
SPARKPOST_API_KEY
```

If you have above keys you don't need to configure anything else. If above environment variables are not exist or if you would like to override these settings you can identifying a different key in the initializer `config/initializers/t-mailer.rb`:

```ruby
T::Mailer.configure do |config|
  config.aws_access_key_id     = "aws access key id"
  config.aws_default_region    = "aws default region"
  config.aws_secret_access_key = "aws secret access key"
  config.sparkpost_api_key     = "sparkpost api key"
end
```

## Usage

When calling the `deliver!` method on the mail object T-mailer returns with a modified mail object with the message ID which returned from the API.

```ruby
message = MyMailer.message(data).deliver!
message.message_id # => 123456789
```

### API Specific Features

`delivery_system` is a specific and required option for T-mailer that the delivery method knows which API should use.

#### Amazon AWS SES

To use AWS SES the `delivery_system` should be `ses`.

Also you can add more AWS SES specific options like `tag: "test"` (required) and `configuration_set_name: "testname"`.

```ruby
mail(from: "from@example.com", to: "to@example.com", delivery_system: "ses", tag: "test", configuration_set_name: "testname")
```

#### SparkPost

To use SparkPost the `delivery_system` should be `sparkpost`.

Also you can add more SparkPost specific options like `tag: "test"`, `options: { open_tracking: true, click_tracking: false, transactional: true }` and `metadata: { website: "testwebsite" }`.

```ruby
mail(from: "from@example.com", to: "to@example.com", delivery_system: "sparkpost", tag: "test", options: { open_tracking: true, click_tracking: false, transactional: true }, metadata: { website: "testwebsite" })
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/100Starlings/t-mailer.
Please use the [issue tracker](https://github.com/100Starlings/t-mailer/issues) if you found any issues. If you would like to contribute to this project, please fork this repository and create a new pull request.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
