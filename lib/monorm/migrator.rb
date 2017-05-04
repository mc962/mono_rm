require 'time'

class MonoRM::Migrator
  def self.migrate(version = nil)
    migration_directory = File.join(PROJECT_ROOT_DIR, 'db', 'migrate')
    # load all migration files
    migrations = MonoRM::Migrator.load_migrations(migration_directory).sort
    if version
      desired_version_timestamp = MonoRM::Migration.convert_file_timestamp_to_time(version)

      current_migration_data = MonoRM::DBConnection.execute(<<-SQL)
        SELECT
          MAX(version)
        FROM
          migrations
      SQL
      current_migration_timestamp_data = current_migration_data.getvalue(0, 0)
      if current_migration_timestamp_data.nil?
        current_migration_timestamp = Time.utc(0) # account for no migrations run yet
      else
        current_migration_timestamp = Time.parse(current_migration_timestamp_data).getutc + Time.parse(current_migration_timestamp_data).utc_offset
      end

      if desired_version_timestamp > current_migration_timestamp
        migrations.each do |migration|
          raw_timestamp, name = MonoRM::Migrator.parse_migration_file(migration)
          processed_timestamp = MonoRM::Migration.convert_file_timestamp_to_time(raw_timestamp)
          migration_class = name.camelcase.constantize.new
          break if processed_timestamp > desired_version_timestamp
          next if MonoRM::Migration.migration_ran?(raw_timestamp)
          migration_class.up
          MonoRM::Migration.add_migration_to_migrations_table(raw_timestamp, name)
        end
      elsif desired_version_timestamp < current_migration_timestamp

        latest_migration_data = MonoRM::Migrator.find_last_migration
        latest_timestamp_data = latest_migration_data.getvalue(0, 0)
        latest_timestamp = Time.parse(latest_timestamp_data).getutc + Time.parse(latest_timestamp_data).utc_offset
        latest_migration_name = latest_migration_data.getvalue(0, 1)

        until latest_timestamp <= desired_version_timestamp


          migration_class = latest_migration_name.camelcase.constantize.new
          migration_class.down
          MonoRM::Migration.remove_migration_from_migrations_table

          latest_migration_data = MonoRM::Migrator.find_last_migration
          latest_raw_timestamp = latest_migration_data.getvalue(0, 0)
          latest_migration_name = latest_migration_data.getvalue(0, 1)
          latest_timestamp = Time.parse(latest_raw_timestamp).getutc + Time.parse(latest_raw_timestamp).utc_offset
        end
      else
        puts 'This is the current version, no migration run'
      end

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
    record_count = MonoRM::DBConnection.execute("SELECT COUNT(*) FROM migrations").getvalue(0,0).to_i

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

  def self.find_last_migration
    MonoRM::DBConnection.execute(<<-SQL)
      SELECT
        version, name
      FROM
        migrations
      WHERE
        version
      IN
        (SELECT MAX(version) FROM migrations);
    SQL

  end
end
