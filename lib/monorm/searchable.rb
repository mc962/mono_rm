module Searchable
  def where(params)
    where_line = params.keys.map do |key|
      "#{key} = INTERPOLATOR_MARK"
    end
    where_line = where_line.join(' AND ')
    param_values = params.values

    data = MonoRM::DBConnection.execute(<<-SQL, *param_values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL
    parse_all(data)
  end

  def first
    data = MonoRM::DBConnection.execute(<<-SQL, limit_val=1)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      ORDER BY
        #{self.table_name}.id ASC
      LIMIT
        limit_val
    SQL
    parse_all(data)
  end

  def last
  end
end

class MonoRM::Base
  extend Searchable
end
