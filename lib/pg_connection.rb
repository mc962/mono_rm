require 'pg'

require 'yaml'

require 'byebug'


# PRINT_QUERIES = ENV['PRINT_QUERIES'] == 'true'




  # # this works for sqlite, will need a more adaptive solution for postgres support
  # dir = File.dirname(__FILE__)
  # DB_NAME = "#{@db_file['default']['database']}.db"
  # SQL_NAME = "#{@db_file['default']['database']}.sql"
  # DB_PATH = File.join(dir, '..', "/db/sqlite_db/#{DB_NAME}")
  # SQL_PATH = File.join(dir, '..', "/db/sqlite_sql/#{SQL_NAME}")
  #


class DBConnection

  def self.open
    DBConnection.load_db_file unless @db_file
    # debugger
    # uri = URI.parse(ENV['DATABASE_URL'])
    @conn = PG::Connection.new(
    dbname: @db_file['default']['database']
    # user: uri.user,
    # password: uri.password,
    # host: uri.host,
    # port: uri.port,
    )
  end

  def self.instance
    DBConnection.open if @conn.nil?

    @conn
  end

  def self.execute(*args)
    sql_statement = args[0]

    args_counter = 1

    interpolated_sql_statement_elements = sql_statement.split(' ').map do |arg|
      if arg == 'INTERPOLATOR_MARK'
        interpolated_arg = "$#{args_counter}"
        args_counter += 1
        interpolated_arg
      else
        arg
      end
    end
    interpolated_sql_statement = interpolated_sql_statement_elements.join(' ')
    args[0] = interpolated_sql_statement
    # stringified_sql = args[0].join(' ')
    interpolated_args = args.slice(1..-1)

# hardcoded_val = ["id", 1]
#   hardcoded_str = "SELECT * FROM dragons WHERE id = $1"
    instance.exec(interpolated_sql_statement, interpolated_args)
  end

  def self.cols_exec(*args)
    args = args.join("\n")


    instance.exec(args)[0].keys
  end

  def self.last_insert_row_id
  end



  def self.load_db_file
    @db_file = begin
      dir = File.dirname(__FILE__)
      database_config_path = File.join(dir, '..', '/config/database.yml')

      YAML.load(File.open(database_config_path))
    rescue ArgumentError => e
      puts "Could not parse database file: #{e.message}"

    end
  end


end
