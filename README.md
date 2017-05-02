# MonoRM

MonoRM is a lightweight Object Relational Mapping (ORM) library that facilitates the creation and
usage of Ruby objects from data retrieved from persistent storage, as well as the insertion and manipulation
of that data into persistent storage. When a new model class extends the 'Base' class, the methods are provided
allowing for interaction with the chosen database.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'monorm'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install monorm

## Usage

A small sample project that can be used to test MonoRM can be found here (coming soon).

Relevant OS database drivers must be set up by user in order for gem and dependencies to install (Instructions for PostgreSQL installation coming soon).

MonoRM was designed to work with several configuration files to allow for user customization.


The following files are required:
- config folder
  - database.yml - This file contains relevant configuration for the database
  - boot.rb - This file (name not enforced) should define a constant named `PROJECT_ROOT_DIR` to represent the root directory of the _project_. It should also call `MonoRM::DBInitializer.load_db_adapter`, which loads the appropriate database adapter file in the gem.
  - model_loader.rb - This file (optional, but recommended), that loads all the models in the model directory that will be used in the application.
- bin folder
  - There should be a file that requires `bundler/setup` and your choice of Ruby console to interact with the application, as well as the boot file from the config folder. Be sure to run the initialization methods from boot before startup, and then start the console
- db folder (for sqlite databases)
  - sqlite_db folder
    - `{database_name}.db` - A database file, with name chosen by the user, is required by sqlite to function. Maintain this folder structure and enter the name (without .db extension) in the `database.yml` file under the _database_ key

The following files are recommended:
- db folder
  - `sqlite_setup.rb` - This is a setup script to setup a sqlite database. The recommended structure is to take a command line argument for the database name, and then run the setup. The setup will need a .db database file name path that will place the database file in the sqlite_db folder. A .sql file written for sqlite3 located in the sqlite_sql to seed the database with is also recommended. The following commands can then be run: `dropdb`, `createdb`, and `sqlite3 path_to_db_name < path_to_sql_file` to recreate the database to the specifications of the sqlite sql file.
  - `pg_setup.rb` - This is a setup script to setup a postgres database. The recommended structure is similar to sqlite, but no db folder/file is needed, just a .sql file written for a postgreSQL database,
  with the command `psql database_name < path_to_sql_file`.
  - sqlite_sql folder
    - db_name.sql - This is a .sql file named for the database to seed containing the relevant sql commands to seed the database, written for a sqlite3 database.
  - pg_sql folder
    - db_name.sql - This is a .sql file named for the database to seed containing the relevant sql commands to seed the database, written for a postgreSQL database.    

- models folder
  - This folder should contain any models that will be used to interact with the database, where each model should inherit from the `MonoRM::Base` class

## Features
- CRUD Actions - Users may create new records in the database, read those records from the database, update certain value for a particular record in the database, and delete records from the database.
- Searching - Users have several searching options available. A record may be found by it's id (`Dragon.find(id)`), or providing a hash to the where method (`Dragon.where(name: 'Bob')`)
- Associations - Additional data related linked by a `foreign_key` to the original object may be obtained through an association method may be created in the particular model file. There are several associations available, belongs_to (`Dragon.rider`), has_many (`Dragon.memories`),
and has_one_through, (`Memory.rider`). Additonal support is planned for a has_many option.

## Database Support

Currently there is support for PostgreSQL and SQLite3 databases. Support for additional databases
may be added in the future.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests (not yet written). You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## TODO

- Documentation and code snippets for major features
- Write RSpec tests
- Support for additional database query methods, including `joins`
- Make `where` lazy and stackable
- Implement Relation class
- Implement validation methods
- Implement `has_many, :through`
- Prefetching using `includes`
- Make convenience utility methods such as `first` and `last`
- Add support for `database.yml`
- Write additional database adapters, such as MySQL

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/monorm. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
