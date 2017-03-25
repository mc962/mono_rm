# require_relative 'sql_object'

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
end

class MonoRM::SQLObject
  extend Searchable
end
