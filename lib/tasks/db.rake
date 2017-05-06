namespace :db do
  task :create do
    load_db_adapter
    load_migrator

    MonoRM::DBConnection.create_database
  end

  task :migrate do
    load_db_adapter
    load_migrator

    version = ENV['VERSION']
    if version
      MonoRM::Migrator.migrate(version)
    else
      MonoRM::Migrator.migrate
    end
  end

  task :rollback do
    load_db_adapter
    load_migrator

    version = ENV['VERSION']
    if version
      MonoRM::Migrator.rollback(version)
    else
      MonoRM::Migrator.rollback
    end
  end

  task :reset do
    load_db_adapter
    load_migrator

    MonoRM::DBConnection.drop_database
    MonoRM::DBConnection.create_database
    MonoRM::Migrator.migrate ## may want to replace with schema:load when ready
  end

  task :drop do
    load_db_adapter
    load_migrator

    MonoRM::DBConnection.drop_database
  end

  task :seed do
    load_db_adapter
    initialize_app    
    require_relative File.join(PROJECT_ROOT_DIR, 'db', 'seeds')
  end
end
