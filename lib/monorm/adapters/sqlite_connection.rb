require 'sqlite3'


PRINT_QUERIES = ENV['PRINT_QUERIES'] == 'true'



class MonoRM::DBConnection


  def self.open
    MonoRM::DBConnection.load_db_path unless @db_path

    @db = SQLite3::Database.new(@db_path)
    @db.results_as_hash = true
    @db.type_translation = true

    @db
  end

  def self.instance
    MonoRM::DBConnection.open if @db.nil?

    @db
  end

  def self.execute(*args)
    print_query(*args)

    interpolated_sql_statement = args[0].gsub(/\bINTERPOLATOR_MARK\b/, '?')

    interpolated_args = args.slice(1..-1)


    instance.execute(interpolated_sql_statement, interpolated_args)
  end

  def self.cols_exec(*args)
    print_query(*args)

    instance.execute2(*args)[0]
  end

  def self.last_insert_row_id
    instance.last_insert_row_id
  end

  def self.load_db_path
    dir = File.dirname(__FILE__)
    db_name = "#{MonoRM::DB_CONFIG['default']['database']}.db"
    @db_path = File.join(MonoRM::PROJECT_ROOT_DIR, "db", "sqlite_db", "#{db_name}")
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
