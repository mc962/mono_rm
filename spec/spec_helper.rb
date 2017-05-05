require "bundler/setup"
require 'dotenv'
require 'pg'
require 'sqlite3'
require 'rspec'
require 'support/factory_girl'

# For testing be sure to place a .env.test file in the ROOT directory of the gem!
Dotenv.load('.env.test')

RSpec.configure do |config|
  # Use color in STDOUT
  config.color = true

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) do
    PROJECT_ROOT_DIR =  Pathname.new(__dir__)
    require "monorm"
    MonoRM::DBInitializer.load_db_adapter
    MonoRM::MigrationInitializer.load_migrator
  end



end
