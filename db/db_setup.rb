database_name = ARGV[0]
raise 'No database specified' unless database_name

def setup_database(db_name)
  dir = File.dirname(__FILE__)
  db_path = File.join(dir, '/', "sqlite_db/#{db_name}.db")
  sql_path = File.join(dir, '/', "sqlite_sql/#{db_name}.sql")

  begin

    puts "WARNING: Following action will reset database to preconfigured SQL file"
    print "\nPress c to continue, or any other key to exit: "
    choice = $stdin.gets.chomp

    if choice == 'c'

      File.delete(db_path) if File.file?(db_path)
      system "dropdb #{db_name}"
      system "createdb #{db_name}"
      system "sqlite3 #{db_path} < #{sql_path}"
    else
      exit(0)
    end
  rescue
    # later do error checking through ruby instead of letting shell throw error, but for now is fine
  end
end

setup_database(database_name)
