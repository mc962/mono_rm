class MonoRM::Migration

  attr_accessor :sql_arguments, :is_migration_table

  def initialize
    @sql_arguments = []
    @is_migration_table = false
  end

  def self.create_migrations_table
    migrator = self.new
    migrator.is_migration_table = true

    migrator.create_table :migrations do |t|
      t.primary_key
      t.timestamp       :version, null: false
      t.string          :name, null: false
    end
  end

  def self.add_migration_to_migrations_table(migration_version, migration_name)
    timestamped_version = migration_version.class == Time ? migration_version : MonoRM::Migration.convert_file_timestamp_to_time(migration_version)

    sql_statement = "INSERT INTO migrations (version, name) VALUES ($1, $2)"

    MonoRM::DBConnection.migrate_exec(sql_statement, timestamped_version, migration_name)
  end

  def self.remove_migration_from_migrations_table
    data = MonoRM::DBConnection.migrate_exec(<<-SQL)
      DELETE
      FROM
        migrations
      WHERE
        version
      IN (
        SELECT
          MAX(version)
        FROM
          migrations
      )
      RETURNING
        name
    SQL

    data.getvalue(0,0)
  end

  def self.migration_ran?(migration_version)
    timestamped_version = MonoRM::Migration.convert_file_timestamp_to_time(migration_version) unless migration_version.class == Time
    timestamped_string = timestamped_version.to_s[0..-5]
    data = MonoRM::DBConnection.migrate_exec(<<-SQL, timestamped_string)
    SELECT
      *
    FROM
      migrations
    WHERE
      version = $1
    LIMIT
    1
    SQL
    if data.count > 0
      true
    else
      false
    end
  end

  # forcing timestamps to be used as identifiers
  def self.convert_file_timestamp_to_time(version)
    version_digits = version.chars
    year = version_digits[0..3].join
    month = version_digits[4..5].join
    day = version_digits[6..7].join
    hour = version_digits[8..9].join
    minute = version_digits[10..11].join
    second = version_digits[12..13].join

    Time.utc(year, month, day, hour, minute, second)
  end


  def execute_migration(sql_statement)
    # wrap this in transaction
    MonoRM::DBConnection.migrate_exec(sql_statement)

  end

  def create_table(table_name, &prc)
    prc.call(self)
    table_arguments = sql_arguments.join(', ')
    sql_table_arguments = "CREATE TABLE #{table_name.to_s} (#{table_arguments})"

    if is_migration_table
      MonoRM::DBConnection.migrate_exec(sql_table_arguments)
      is_migration_table = false
    else
      puts "-- create_table(:#{table_name})"
      before_migrate = Time.now
      self.execute_migration(sql_table_arguments)
      after_migrate = Time.now
      migrate_duration = after_migrate - before_migrate
      puts "   -> #{migrate_duration}s"
    end
  end

  def rename_table(old_table_name, new_table_name)
    puts "-- rename_table(:#{table_name})"
    before_migrate = Time.now

    sql_table_arguments = "ALTER TABLE #{old_table_name.to_s} RENAME TO #{new_table_name.to_s}"
    self.execute_migration(sql_table_arguments)

    after_migrate = Time.now
    migrate_duration = after_migrate - before_migrate
    puts "   -> #{migrate_duration}s"
  end

  def drop_table(table_name)
    puts "-- drop_table(:#{table_name})"
    before_migrate = Time.now
    sql_table_arguments = "DROP TABLE #{table_name.to_s}"
    self.execute_migration(sql_table_arguments)

    after_migrate = Time.now
    migrate_duration = after_migrate - before_migrate
    puts "   -> #{migrate_duration}s"
  end

  def add_column(table_name, column_name, column_type, constraints = {}, foreign_table_name = nil)
    # if specified a foreign table, send that argument along (really only for fkey), otherwise proceed normally
    if foreign_table_name
      sql_column_args = send(column_type.to_sym, column_name, constraints, foreign_table_name)
    else
      sql_column_args = send(column_type.to_sym, column_name, constraints)
    end
# because we are keeping track of an array of args, but add_column should only be looking at the last thing we added
    sql_column = sql_column_args.last
    sql_table_arguments = "ALTER TABLE #{table_name.to_s} ADD COLUMN #{sql_column}"

    puts "-- add_column(#{column_type}:#{column_name})"
    before_migrate = Time.now

    self.execute_migration(sql_table_arguments)

    after_migrate = Time.now
    migrate_duration = after_migrate - before_migrate
    puts "   -> #{migrate_duration}s"
  end

  def rename_column(table_name, old_column_name, new_column_name)
    sql_table_arguments = "ALTER TABLE #{table_name.to_s} RENAME COLUMN #{old_column_name} TO #{new_column_name}"
    puts "-- rename_column(:#{column_name})"
    before_migrate = Time.now

    self.execute_migration(sql_table_arguments)

    after_migrate = Time.now
    migrate_duration = after_migrate - before_migrate
    puts "   -> #{migrate_duration}s"
  end

  def remove_column(table_name, column_name)
    sql_table_arguments = "ALTER TABLE #{table_name.to_s} DROP COLUMN #{column_name.to_s}"
    puts "-- drop_column(:#{column_name})"
    before_migrate = Time.now

    self.execute_migration(sql_table_arguments)

    after_migrate = Time.now
    migrate_duration = after_migrate - before_migrate
    puts "   -> #{migrate_duration}s"
  end

  # recommended to only add 1 constraint at a time, only column-level constraint alterations supported at this time
  def add_constraint(table_name, column_name, constraint)
    raise 'Too many constraints to edit' if constraint.count > 1
    sql_table_arguments = "ALTER TABLE #{table_name.to_s} ALTER COLUMN #{column_name.to_s} SET #{evaluate_constraints(constraint)}"
    puts "-- add_constraint(:#{constraint.key})"
    before_migrate = Time.now

    self.execute_migration(sql_table_arguments)

    after_migrate = Time.now
    migrate_duration = after_migrate - before_migrate
    puts "   -> #{migrate_duration}s"
  end

  def remove_constraint(table_name, column_name, constraint)
    raise 'Too many constraints to edit' if constraint.count > 1
    sql_table_arguments = "ALTER TABLE #{table_name.to_s} ALTER COLUMN #{column_name.to_s} DROP #{evaluate_constraints(constraint)}"
    puts "-- remove_constraint(:#{constraint.key})"
    before_migrate = Time.now

    self.execute_migration(sql_table_arguments)

    after_migrate = Time.now
    migrate_duration = after_migrate - before_migrate
    puts "   -> #{migrate_duration}s"
  end

# WILL need to add foreign key cosntraint back on id if you want it back
  def remove_foreign_key(table_name, column_name, foreign_table_name)
    sql_table_arguments = "ALTER TABLE #{table_name.to_s} DROP CONSTRAINT #{table_name}_#{column_name}_fkey"
    puts "-- remove_foreign_key(:#{column_name})"
    before_migrate = Time.now
    self.execute_migration(sql_table_arguments)
    after_migrate = Time.now
    migrate_duration = after_migrate - before_migrate
    puts "   -> #{migrate_duration}s"
  end

  def add_index(table_name, column_name, constraints ={})
    # we only want unique constraints for add_index
    raise 'Invalid index constraints' if constraints.count > 1 && constraints.keys.any?{|constraint| constraint != :unique }
    sql_table_arguments = "CREATE #{evaluate_constraints(constraints)} INDEX #{column_name.to_s}_index ON #{table_name.to_s.upcase}(#{column_name.to_s})"
    puts "-- add_index(:#{column_name})"
    before_migrate = Time.now

    self.execute_migration(sql_table_arguments)

    after_migrate = Time.now
    migrate_duration = after_migrate - before_migrate
    puts "   -> #{migrate_duration}s"
  end

  def remove_index(column_name)
    sql_table_arguments = "DROP INDEX #{column_name.to_s}_index"
    puts "-- remove_index(:#{column_name})"
    before_migrate = Time.now

    self.execute_migration(sql_table_arguments)

    after_migrate = Time.now
    migrate_duration = after_migrate - before_migrate
    puts "   -> #{migrate_duration}s"
  end

  def string(column_name, constraints = {})
    sql_arguments << "#{column_name.to_s} character varying(255) #{evaluate_constraints(constraints)}"
  end

  def text(column_name, constraints = {})
   sql_arguments << "#{column_name.to_s} TEXT #{evaluate_constraints(constraints)}"
  end

  def integer(column_name, constraints = {})
    sql_arguments << "#{column_name.to_s} INTEGER #{evaluate_constraints(constraints)}"
  end

  def float(column_name, constraints = {})
    sql_arguments << "#{column_name.to_s} FLOAT #{evaluate_constraints(constraints)}"
  end

  def decimal(column_name, constraints = {})
    sql_arguments << "#{column_name.to_s} DECIMAL #{evaluate_constraints(constraints)}"
  end

  def boolean(column_name, constraints = {})
    sql_arguments << "#{column_name.to_s} BOOLEAN #{evaluate_constraints(constraints)}"
  end

  def binary(column_name, constraints = {})
    sql_arguments << "#{column_name.to_s}  BYTEA #{evaluate_constraints(constraints)}"
  end

  def date(column_name, constraints = {})
    sql_arguments << "#{column_name.to_s} DATE #{evaluate_constraints(constraints)}"
  end

  def time(column_name, constraints = {})
    sql_arguments << "#{column_name.to_s} TIME #{evaluate_constraints(constraints)}"
  end

  def timestamp(column_name, constraints = {})
    sql_arguments << "#{column_name.to_s} TIMESTAMP #{evaluate_constraints(constraints)}"
  end

  def evaluate_constraints(constraints)
    stringified_constraints = constraints.map do |constraint, val|
      case constraint.to_sym
      when :null
        if val == false
          'NOT NULL'
        end
      when :unique
        if val == true
          'UNIQUE'
        end
      # default values not currently supported
      # when :default
      #   # blank spaces will be stripped from default values
      #   stripped_val = val.strip
      #   raise 'Use null: false instead of a blank string constraint' if stripped_val == ''
      #   "DEFAULT \'#{stripped_val}\'"
      else
        raise 'Invalid Constraint!'
      end
    end
    stringified_constraints.join(' ')
  end

  def primary_key(column_name = 'id')
    sql_arguments << "#{column_name} SERIAL PRIMARY KEY NOT NULL"
  end

# recommended to run migrations involving foreign_keys separate from the table you are creating that they reference
  def foreign_key(column_name, constraints = {}, table_name)
    sql_arguments << "#{column_name} INTEGER REFERENCES #{table_name} ON DELETE CASCADE #{evaluate_constraints(constraints)}"
  end

end
