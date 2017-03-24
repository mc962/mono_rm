database_name = ARGV[0]
raise 'No database specified' unless database_name

def setup_database(db_name)
  dir = File.dirname(__FILE__)

  sql_path = File.join(dir, '/', "pg_sql/#{db_name}.sql")

  begin

    puts "WARNING: Following action will reset database to preconfigured SQL file"
    print "\nPress c to continue, or any other key to exit: "
    choice = $stdin.gets.chomp

    if choice == 'c'

      system "dropdb #{db_name}"
      system "createdb #{db_name}"
      system "psql dragons < #{sql_path}"
    else
      exit(0)
    end
  rescue
    # later do error checking through ruby instead of letting shell throw error, but for now is fine
  end
end

setup_database(database_name)
