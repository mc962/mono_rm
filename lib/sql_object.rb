require 'active_support/inflector'

require_relative './db_connection'
require_relative './searchable'
require_relative './associatable'


class SQLObject

  def self.columns
    @cols ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    @cols[0].map{|col| col.to_sym}

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
    data = DBConnection.execute(<<-SQL)
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
    record = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
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
    question_marks = ['?'] * attribute_values.length
    question_marks = question_marks.join(', ')
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name}(#{col_names})
      VALUES
        (#{question_marks})
    SQL

    send(:id=, DBConnection.last_insert_row_id)
  end

  def update
    attribs = attribute_values.drop(1)
    id = self.id

    cols = self.class.columns.drop(1)

    set_lines = cols.map do |col|
      "#{col} = ?"
    end

    set_lines = set_lines.join(', ')

    DBConnection.execute(<<-SQL, *attribs, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_lines}
      WHERE
        id = ?
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
    DBConnection.execute(<<-SQL, id)
      DELETE
      FROM
        #{self.class.table_name}
      WHERE
        id = ?
    SQL
  end
end
