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
    timestamped_version = MonoRM::Migration.convert_file_timestamp_to_time(migration_version) unless migration_version.class == Time

    sql_statement = "INSERT INTO migrations (version, name) VALUES ($1, $2)"

    MonoRM::DBConnection.execute(sql_statement, timestamped_version, migration_name)
  end

  def self.remove_migration_from_migrations_table
    data = MonoRM::DBConnection.execute(<<-SQL)
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
    data = MonoRM::DBConnection.execute(<<-SQL, timestamped_string)
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
    MonoRM::DBConnection.execute(sql_statement)

  end

  def create_table(table_name, &prc)
    prc.call(self)
    table_arguments = sql_arguments.join(', ')
    sql_table_arguments = "CREATE TABLE #{table_name.to_s} (#{table_arguments})"

    if is_migration_table
      MonoRM::DBConnection.execute(sql_table_arguments)
      is_migration_table = false
    else
      self.execute_migration(sql_table_arguments)
    end
  end

  def rename_table(old_table_name, new_table_name)
    sql_table_arguments = "ALTER TABLE #{old_table_name.to_s} RENAME TO #{new_table_name.to_s}"
    self.execute_migration(sql_table_arguments)
  end

  def drop_table(table_name)
    sql_table_arguments = "DROP TABLE #{table_name.to_s}"
    self.execute_migration(sql_table_arguments)
  end

  def add_column(table_name, column_name, column_type, constraints)

    sql_column = send(column_type.to_sym, column_name, constraints)
    sql_table_arguments = "ALTER TABLE #{table_name.to_s} ADD COLUMN #{sql_column}"
    self.execute_migration(sql_table_arguments)
  end

  def rename_column(table_name, old_column_name, new_column_name)
    sql_table_arguments = "ALTER TABLE #{table_name.to_s} RENAME COLUMN #{old_column_name} TO #{new_column_name}"
    self.execute_migration(sql_table_arguments)
  end

  def remove_column(table_name, column_name)
    sql_table_arguments = "ALTER TABLE #{table_name.to_s} DROP COLUMN #{column_name.to_s}"
    self.execute_migration(sql_table_arguments)
  end

  # recommended to only add 1 constraint at a time, only column-level constraint alterations supported at this time
  def add_constraint(table_name, column_name, constraint)
    raise 'Too many constraints to edit' if constraint.count > 1
    sql_table_arguments = "ALTER TABLE #{table_name.to_s} ALTER COLUMN #{column_name.to_s} SET #{evaluate_constraints(constraint)}"
    self.execute_migration(sql_table_arguments)
  end

  def remove_constraint(table_name, column_name, constraint)
    raise 'Too many constraints to edit' if constraint.count > 1
    sql_table_arguments = "ALTER TABLE #{table_name.to_s} ALTER COLUMN #{column_name.to_s} DROP #{evaluate_constraints(constraint)}"
    self.execute_migration(sql_table_arguments)
  end

  def add_index(table_name, column_name, constraints)
    # we only want unique constraints for add_index
    raise 'Invalid index constraints' if constraints.count > 1 && constraints.keys.any?{|constraint| constraint != :unique }
    sql_table_arguments = "CREATE #{evaluate_constraints(constraints)} INDEX #{column_name.to_s}_index ON #{table_name.to_s.upcase}(#{column_name.to_s})"
    self.execute_migration(sql_table_arguments)
  end

  def remove_index(column_name)
    #
    # sql_arguments = "DROP INDEX #{column_name.to_s}_index"
    # self.execute_migration(sql_table_arguments)
  end

  def string(column_name, constraints)
    sql_arguments << "#{column_name.to_s} character varying(255) #{evaluate_constraints(constraints)}"
  end

  def text(column_name, constraints)
   sql_arguments << "#{column_name.to_s} TEXT #{evaluate_constraints(constraints)}"
  end

  def integer(column_name, constraints)
    sql_arguments << "#{column_name.to_s} INTEGER #{evaluate_constraints(constraints)}"
  end

  def float(column_name, constraints)
    sql_arguments << "#{column_name.to_s} FLOAT #{evaluate_constraints(constraints)}"
  end

  def decimal(column_name, constraints)
    sql_arguments << "#{column_name.to_s} DECIMAL #{evaluate_constraints(constraints)}"
  end

  def boolean(column_name, constraints)
    sql_arguments << "#{column_name.to_s} BOOLEAN #{evaluate_constraints(constraints)}"
  end

  def binary(column_name, constraints)
    sql_arguments << "#{column_name.to_s}  BINARY #{evaluate_constraints(constraints)}"
  end

  def date(column_name, constraints)
    sql_arguments << "#{column_name.to_s} DATE #{evaluate_constraints(constraints)}"
  end

  def time(column_name, constraints)
    sql_arguments << "#{column_name.to_s} TIME #{evaluate_constraints(constraints)}"
  end

  def date_time(column_name, constraints)
    sql_arguments << "#{column_name.to_s} DATE_TIME #{evaluate_constraints(constraints)}"
  end

  def timestamp(column_name, constraints)
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
      when :default
        # blank spaces will be stripped from default values
        stripped_val = val.strip
        raise 'Use null: false instead of a blank string constraint' if stripped_val == ''
        "DEFAULT #{stripped_val}"
      else
        raise 'Invalid Constraint!'
      end
    end
    stringified_constraints.join(' ')
  end

  def primary_key(column_name = 'id')
    sql_arguments << "#{column_name} SERIAL PRIMARY KEY NOT NULL"
  end

  def foreign_key(column_name, table_name, constraints)
    sql_arguments << "#{column_name} INTEGER REFERENCES #{table_name} #{evaluate_constraints(constraints)}"
  end

end
