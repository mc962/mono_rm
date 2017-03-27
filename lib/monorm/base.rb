require 'active_support/inflector'

require 'monorm/associatable'
require 'monorm/searchable'

class MonoRM::Base

  def self.columns
    @cols ||= MonoRM::DBConnection.cols_exec(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      LIMIT
        1
    SQL

    @cols.map{|col| col.to_sym}

  end

  def self.finalize!
    self.columns.each do |col|
      define_method(:"#{col}=") { |arg| self.attributes[col] = arg }
      define_method(:"#{col}") {self.attributes[col]}
    end

  end

  def self.table_name=(table_name = nil)
    @table_name = table_name
  end

  def self.table_name
    return @table_name unless @table_name.nil?
    @table_name = self.to_s.tableize
  end

  def self.all
    data = MonoRM::DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    parse_all(data)
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    record = MonoRM::DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = INTERPOLATOR_MARK
    SQL
    self.parse_all(record).first

  end

  def initialize(params = {})

    params.each do |attr_name, val|
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name.to_sym)
      send(:"#{attr_name}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values

    self.attributes.values.map {|attribute| attribute}
  end

  def insert
    col_names = self.class.columns.drop(1).join(', ')
    question_marks = ['INTERPOLATOR_MARK'] * attribute_values.length
    question_marks = question_marks.join(', ')
    MonoRM::DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name}(#{col_names})
      VALUES
        (#{question_marks})
    SQL

    send(:id=, MonoRM::DBConnection.last_insert_row_id)
  end

  def update
    attribs = attribute_values.drop(1)
    id = self.id

    cols = self.class.columns.drop(1)

    set_lines = cols.map do |col|
      "#{col} = INTERPOLATOR_MARK"
    end

    set_lines = set_lines.join(', ')

    MonoRM::DBConnection.execute(<<-SQL, *attribs, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_lines}
      WHERE
        id = INTERPOLATOR_MARK
    SQL

  end

  def save
    if self.class.find(self.id)
      update
    else
      insert
    end
  end

  def destroy
    id = self.id
    MonoRM::DBConnection.execute(<<-SQL, id)
      DELETE
      FROM
        #{self.class.table_name}
      WHERE
        id = INTERPOLATOR_MARK
    SQL
  end
end
