require "monorm/version"
require 'yaml'

module MonoRM

  def self.root
   File.dirname __dir__
  end

  def self.config
    File.join root, 'config'
  end

  def self.db_config
    File.join config, 'database.yml'
  end

  def self.bin
    File.join root, 'bin'
  end

  def self.lib
    File.join root, 'lib'
  end

  def self.monorm
    File.join lib, 'monorm'
  end

  MONORM_DB_CONFIG = YAML.load(File.open("#{self.db_config}"))
  # runtime loading of database conn file, db sql file, and db, if necessary for sqlite


  def load_db_adapter

    adapter = MONORM_DB_CONFIG['default']['adapter']
    case adapter
    when 'postgresql'
      adapter_path = File.join self.monorm, 'adapters', 'pg_connection'

      require_relative adapter_path# "#{self.monorm}/adapters/pg_connection"
    when 'sqlite3'
      adapter_path = File.join self.monorm, 'adapters', 'sqlite_connection'

      require_relative adapter_path
    else
      raise 'Database type not found!'
    end
  end

end
