namespace :db do
  task :create do
    MonoRM::DBConnection.create_database
  end

  task :migrate do
    version = ENV['VERSION']
    if version
      MonoRM::Migrator.migrate(version)
    else
      MonoRM::Migrator.migrate(version)
    end
  end

  task :rollback do
    version = ENV['VERSION']
    if version
      MonoRM::Migrator.rollback(version)
    else
      MonoRM::Migrator.rollback(version)
    end
  end

  task :reset do
    MonoRM::DBConnection.drop_database
    MonoRM::DBConnection.create_database
    MonoRM::Migrator.migrate ## may want to replace with schema:load when ready
  end

  task :drop do
    MonoRM::DBConnection.drop_database
  end

  task :seed do
    require_relative File.join(PROJECT_ROOT_DIR, 'db', 'seeds')
  end
end
