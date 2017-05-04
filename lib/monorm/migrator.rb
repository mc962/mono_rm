class MonoRM::Migrator
  def self.migrate(version = nil)
    migration_directory = File.join(PROJECT_ROOT_DIR, 'db', 'migrate')
    # load all migration files
    migrations = MonoRM::Migrator.load_migrations(migration_directory).sort
    if version
      raise 'Not yet implemented, will be used to run specific migration by timestamped version number'
    else

      # iterate through each migration, and call the up/ migrate forward method
      migrations.each do |migration|
        raw_timestamp, name = MonoRM::Migrator.parse_migration_file(migration)
        next if MonoRM::Migration.migration_ran?(raw_timestamp)
        migration_class = name.camelcase.constantize.new
        migration_class.up
        MonoRM::Migration.add_migration_to_migrations_table(raw_timestamp, name)
      end
    end
  end

  def self.rollback(rollback_count = 1)
    migration_directory = File.join(PROJECT_ROOT_DIR, 'db', 'migrate')
    migrations = load_migrations(migration_directory)
    # get table count to raise error is rollback count exceeds number of migrations in database
    # uses count to find this, if you have a billion migrations and it becomes slow then you are probably doing migrations wrong, consider cleaning the folder out
    record_count = DBConnection.execute("SELECT COUNT(*) FROM migrations").getvalue(0,0).to_i

    raise "Too many rollbacks specified, max allowed in this transaction is #{record_count}" if rollback_count.to_i > record_count

    rollback_count.to_i.times do
      table_name = MonoRM::Migration.remove_migration_from_migrations_table
      migration_class = table_name.camelcase.constantize.new
      migration_class.down
    end
  end



  def self.load_migrations(migration_directory)

    migration_files = Dir["#{migration_directory}/*.rb"]
    migration_files.each do |file|
      require_relative file
    end
    return migration_files
  end

  def self.parse_migration_file(file)
    base_file_name = File.basename(file, '.rb')
    file_name_components = base_file_name.split('_')
    migration_timestamp = file_name_components[0]
    migration_name = file_name_components[1..-1].join('_')
    return migration_timestamp, migration_name
  end

end
