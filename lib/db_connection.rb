require 'sqlite3'
require 'yaml'
PRINT_QUERIES = ENV['PRINT_QUERIES'] == 'true'
# https://tomafro.net/2010/01/tip-relative-paths-with-file-expand-path
# ROOT_FOLDER = File.join(File.dirname(__FILE__), '..')
# DRAGONS_SQL_FILE = File.join(ROOT_FOLDER, 'dragons.sql')
# DRAGONS_DB_FILE = File.join(ROOT_FOLDER, 'dragons.db')

# CATS_SQL_FILE = File.join(ROOT_FOLDER, 'cats.sql')
# CATS_DB_FILE = File.join(ROOT_FOLDER, 'cats.db')


# begin
#   SQL_DB = database_path
#   # DBConnection.open(SQL_DB)
# rescue ArgumentError => e
#   puts "Could not open database file: #{e.message}"
#   exit(1);
# end

  database_file = begin
    dir = File.dirname(__FILE__)
    database_config_path = File.join(dir, '..', '/config/database.yml')

    YAML.load(File.open(database_config_path))
  rescue ArgumentError => e
    puts "Could not parse database file: #{e.message}"

  end

  # this works for sqlite, will need a more adaptive solution for postgres support
  dir = File.dirname(__FILE__)
  DB_NAME = "#{database_file['default']['database']}.db"
  SQL_NAME = "#{database_file['default']['database']}.sql"
  DB_PATH = File.join(dir, '..', "/db/sqlite_db/#{DB_NAME}")
  SQL_PATH = File.join(dir, '..', "/db/sqlite_sql/#{SQL_NAME}")


class DBConnection


  def self.open(db_file_name)
    @db = SQLite3::Database.new(db_file_name)
    @db.results_as_hash = true
    @db.type_translation = true

    @db
  end

  def self.reset
    # commands = [
    #   "rm '#{DB_PATH}'",
    #   "cat '#{SQL_PATH}' | sqlite3 '#{DB_PATH}'"
    #   # "rm '#{DRAGONS_DB_FILE}'",
    #   # "cat '#{DRAGONS_SQL_FILE}' | sqlite3 '#{DRAGONS_DB_FILE}'"
    # ]
    #
    # commands.each { |command| `#{command}` }
    DBConnection.open(DB_PATH)
    # DBConnection.open(DRAGONS_DB_FILE)
  end

  def self.instance
    reset if @db.nil?

    @db
  end

  def self.execute(*args)
    print_query(*args)
    instance.execute(*args)
  end

  def self.execute2(*args)
    print_query(*args)
    instance.execute2(*args)
  end

  def self.last_insert_row_id
    instance.last_insert_row_id
  end

  private

  def self.print_query(query, *interpolation_args)
    return unless PRINT_QUERIES

    puts '--------------------'
    puts query
    unless interpolation_args.empty?
      puts "interpolate: #{interpolation_args.inspect}"
    end
    puts '--------------------'
  end
end
