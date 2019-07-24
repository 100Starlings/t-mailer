
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "t/mailer/version"

Gem::Specification.new do |spec|
  spec.name          = "t-mailer"
  spec.version       = T::Mailer::VERSION
  spec.authors       = ["Norbert Szivós"]
  spec.email         = ["sysqa@yahoo.com"]

  spec.summary       = %q{T-mailer from the age of dinosaurs}
  spec.description   = %q{Delivery Method for Rails ActionMailer to send emails via API using raw/rfc822 message type}
  spec.homepage      = "https://github.com/100Starlings/t-mailer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec",        "~> 3.0"
  spec.add_development_dependency "webmock",      "~> 3.0"
  spec.add_development_dependency "mail",         "~> 2.5"
  spec.add_development_dependency "aws-sdk-ses",  "~> 1.0"
  spec.add_development_dependency "simple_spark", "~> 1.0"
end
