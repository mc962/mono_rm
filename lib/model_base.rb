require 'yaml'

require_relative './sql_object'
# require_relative '../config/database.yml'

database_file = begin
  dir = File.dirname(__FILE__)
  database_path = File.join(dir, '..', '/config/database.yml')

  YAML.load(File.open(database_path))
rescue ArgumentError => e
  puts "Could not parse database file: #{e.message}"

end

# this works for sqlite, will need a more adaptive solution for postgres support
SQL_DB = "#{database_file['default']['database']}.db"

DBConnection.open(SQL_DB)


class ModelBase < SQLObject


end
