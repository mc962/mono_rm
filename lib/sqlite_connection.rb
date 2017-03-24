require 'sqlite3'
require 'yaml'

PRINT_QUERIES = ENV['PRINT_QUERIES'] == 'true'

class DBConnection


  def self.open
    DBConnection.load_db_path unless @db_path

    @db = SQLite3::Database.new(@db_path)
    @db.results_as_hash = true
    @db.type_translation = true

    @db
  end

  def self.instance
    DBConnection.open if @db.nil?

    @db
  end

  def self.execute(*args)
    print_query(*args)

    sql_statement = args[0]
    interpolated_sql_statement_elements = sql_statement.split(' ').map do |arg|
      if arg == 'INTERPOLATOR_MARK'
        interpolated_arg = "?"
      else
        arg
      end
    end
    interpolated_sql_statement = interpolated_sql_statement_elements.join(' ')
    args[0] = interpolated_sql_statement

    interpolated_args = args.slice(1..-1)


    instance.execute(interpolated_sql_statement, interpolated_args)
  end

# execute2 returns array of rows if no block specified
  def self.cols_exec(*args)
    print_query(*args)

    instance.execute2(*args)[0]
  end

  def self.last_insert_row_id
    instance.last_insert_row_id
  end

  def self.load_db_path
    dir = File.dirname(__FILE__)
    db_name = "#{DB_CONFIG['default']['database']}.db"
    @db_path = File.join(dir, '..', "/db/sqlite_db/#{db_name}")
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
