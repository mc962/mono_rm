require 'yaml'
require 'erb'
require 'uri'

require "monorm/version"

require 'monorm/base'


MonoRM::PROJECT_ROOT_DIR = PROJECT_ROOT_DIR

module MonoRM

  def self.root

    PROJECT_ROOT_DIR

  end

  def self.config
    File.join root, 'config'
  end

  def self.db_config
    File.join config, 'database.yml'
  end

  def self.lib
    File.join root, 'lib'
  end
  #
  def self.monorm
    File.join lib, 'monorm'
  end

  class MonoRM::DBInitializer
    def self.load_db_adapter

      adapter = URI.parse(ENV['DATABASE_URL']).scheme

      case adapter
      when 'postgres'
        adapter_path = File.join('monorm', 'adapters', 'pg_connection')
        require adapter_path
      when 'sqlite'
        adapter_path = File.join('monorm', 'adapters', 'sqlite_connection')
        require adapter_path
      else
        raise 'Database type not found!'
      end
    end
  end

  class MonoRM::MigrationInitializer
    def self.load_migrator
      migrator = URI.parse(ENV['DATABASE_URL']).scheme
      case migrator
      when 'postgres'
        migrator_path = File.join('monorm', 'migrators', 'pg_migration')
        require migrator_path
      when 'sqlite'
        migrator_path = File.join('monorm', 'migrators', 'sqlite_migration')
        require migrator_path
      else
        raise 'Database type not found!'
      end
    end
  end

  class MonoRM::Migrator
    def self.migrate(version = nil)
      migration_directory = File.join(PROJECT_ROOT_DIR, 'db', 'migrate')
      # load all migration files
      migrations = MonoRM::Migrator.load_migrations(migration_directory)
      if version
        raise 'Not yet implemented, will be used to run specific migration by timestamped version number'
      else

        # iterate through each migration, and call the up/ migrate forward method
        migrations.each do |migration|
          raw_timestamp, name = MonoRM::Migrator.parse_migration_file(migration)
          next if MonoRM::Migration.migration_ran?(raw_timestamp)
          migration_class = name.camelcase.constantize.new
          migration_class.up
          MonoRM::Migration.add_migration_to_migrations_table(raw_timestamp, name)
        end
      end
    end

    def self.rollback(rollback_count = 1)
      migration_directory = File.join(PROJECT_ROOT_DIR, 'db', 'migrate')
      migrations = load_migrations(migration_directory)
      # get table count to raise error is rollback count exceeds number of migrations in database
      # uses count to find this, if you have a billion migrations and it becomes slow then you are probably doing it wrong
      record_count = DBConnection.execute("SELECT COUNT(*) FROM migrations").getvalue(0,0).to_i

      raise "Too many rollbacks specified, max allowed in this transaction is #{record_count}" if rollback_count.to_i > record_count
      # raise 'Not yet implemented, will be used to rollback migrations in order of timestamp, given number of times to do so. Default is 1' if count > 1
      # count.times
      rollback_count.to_i.times do
        table_name = MonoRM::Migration.remove_migration_from_migrations_table
        migration_class = table_name.camelcase.constantize.new
        migration_class.down
      end
    end



  def self.load_migrations(migration_directory)

    migration_files = Dir["#{migration_directory}/*.rb"]
    migration_files.each do |file|
      require_relative file
    end
    return migration_files
  end

  def self.parse_migration_file(file)
    base_file_name = File.basename(file, '.rb')
    file_name_components = base_file_name.split('_')
    migration_timestamp = file_name_components[0]
    migration_name = file_name_components[1..-1].join('_')
    return migration_timestamp, migration_name
  end

end
  # File.basename(MIGRATION_FILES[0], '.rb') -> gets the specific file name
  # and lops off the .rb
  # basename.split('_'), extract the first thing as the number
  # that will go in the schema table, and the rest of the bits of the array
  # can then be joined back into a new string like create_table_swords

  # then can run .camelcase -> .constantize to get a class constant for that file
  # then should probably instantiate with .new, and then can run up or down on that instance

end
