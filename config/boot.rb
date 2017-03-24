require 'yaml'

require_relative './model_loader'


def load_db_config_file
  dir = File.dirname(__FILE__)
  db_config_path = File.join(dir, '/')
end

def load_db_adapter
  dir = File.dirname(__FILE__)
  folder_path = File.join(dir, '../', "lib/")

  adapter = DB_CONFIG['default']['adapter']
  case adapter
  when 'postgresql'
    require_relative "#{folder_path}/pg_connection"

  when 'sqlite3'
    require_relative "#{folder_path}/sqlite_connection"
  else
    raise 'Database type not found!'
  end
end

folder_path = load_db_config_file

DB_CONFIG = YAML.load(File.open("#{folder_path}database.yml"))
