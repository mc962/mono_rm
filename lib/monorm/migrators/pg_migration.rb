class MonoRM::Migration

  attr_accessor :sql_arguments

  def initialize
    @sql_arguments = []
  end

  def create_table(table_name, &prc)
    prc.call(self)
    debugger
    table_arguments = sql_arguments.join(', ')
    sql_table_arguments = "CREATE TABLE #{table_name.to_s} (#{table_arguments})"

    # execute sql statement
    MonoRM::DBConnection.execute(sql_table_arguments)
  end

  def add_column(table_name)

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

  def float(column_name)
    sql_arguments << "#{column_name.to_s} FLOAT  #{evaluate_constraints(constraints)}"
  end

  def decimal(column_name)
    sql_arguments << "#{column_name.to_s} DECIMAL  #{evaluate_constraints(constraints)}"
  end

  def boolean(column_name)
    sql_arguments << "#{column_name.to_s} BOOLEAN  #{evaluate_constraints(constraints)}"
  end

  def binary(column_name)
    sql_arguments << "#{column_name.to_s}  BINARY #{evaluate_constraints(constraints)}"
  end

  def date(column_name)
    sql_arguments << "#{column_name.to_s} DATE #{evaluate_constraints(constraints)}"
  end

  def time(column_name)
    sql_arguments << "#{column_name.to_s} TIME  #{evaluate_constraints(constraints)}"
  end

  def date_time(column_name)
    sql_arguments << "#{column_name.to_s} DATE_TIME  #{evaluate_constraints(constraints)}"
  end

  def timestamps(column_name)
    sql_arguments << "#{column_name.to_s} TIMESTAMP #{evaluate_constraints(constraints)}"
  end

  def evaluate_constraints(constraints)
    debugger
    stringified_constraints = constraints.map do |constraint, val|
      case constraint.to_sym
      when !(:null)
        'NOT NULL'
      end

      when :default
        "DEFAULT #{val}"
      end

      else
        raise 'Invalid Constraint!'
      end

    stringified_constraints.join(' ')
  end

  def primary_key(column_name = 'id')
    sql_arguments << "#{column_name} SERIAL PRIMARY KEY NOT NULL"
  end
# limit to primary_key for now
  def foreign_key(column_name, table_name, constraints)
    sql_arguments << "#{column_name} INTEGER REFERENCES #{table_name} #{evaluate_constraints(constraints)}"
  end

end
