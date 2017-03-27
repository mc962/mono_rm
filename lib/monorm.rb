require 'yaml'

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
  #
  # def self.bin
  #   File.join root, 'bin'
  # end
  #
  def self.lib
    File.join root, 'lib'
  end
  #
  def self.monorm
    File.join lib, 'monorm'
  end

  DB_CONFIG = YAML.load(File.open("#{self.db_config}"))

  class MonoRM::DBInitializer
    def self.load_db_adapter

      adapter = DB_CONFIG['default']['adapter']
      case adapter
      when 'postgresql'
        adapter_path = File.join('monorm', 'adapters', 'pg_connection')
        require adapter_path
      when 'sqlite3'
        adapter_path = File.join('monorm', 'adapters', 'sqlite_connection')
        require adapter_path
      else
        raise 'Database type not found!'
      end
    end
  end

end
