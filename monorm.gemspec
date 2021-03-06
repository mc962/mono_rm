# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'monorm/version'

Gem::Specification.new do |spec|
  spec.name          = "monorm"
  spec.version       = MonoRM::VERSION
  spec.authors       = ["Michael Chilton"]
  spec.email         = ["michaelc962@yahoo.com"]

  spec.summary       = %q{MonoRM is a small ORM library designed to make interacting with the database easier.}
  spec.description   = %q{MonoRM is a small ORM library designed to make interacting with the database easier. It allows for intereaction with multiple database types, model relations, and features such as basic CRUD actions. It also supports a basic database migration system.}
  spec.homepage      = "https://github.com/mc962/monorm"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org/"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'byebug', '~> 9.0'
  spec.add_development_dependency 'pry', '~> 0.10.4'
  spec.add_development_dependency 'dotenv', '~> 2.2'
  spec.add_development_dependency 'factory_girl', '~> 4.8'
  spec.add_development_dependency 'pg', '~> 0.18'
  spec.add_development_dependency 'sqlite3', '~> 1.3'


  spec.add_runtime_dependency 'activesupport', '~> 5.0'

  spec.required_ruby_version = '~> 2.0'

end
