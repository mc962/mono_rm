require 'pg'

class MonoRM::DBConnection

  def self.open
    uri = URI.parse(ENV['DATABASE_URL'])
    @conn = PG::Connection.new(
    user: uri.user,
    password: uri.password,
    host: uri.host,
    port: uri.port,
    dbname: uri.path[1..-1]
    )

    @conn
  end

  def self.instance
    MonoRM::DBConnection.open if @conn.nil?

    @conn
  end

  def self.execute(*args)
    sql_statement = args[0]

    args_counter = 1

    should_return_id = false

    interpolated_sql_statement_elements = sql_statement.split(' ').map do |arg|
      should_return_id = true if /\bINSERT\b/.match(arg)
      if /\bINTERPOLATOR_MARK\b/.match(arg)
        interpolated_arg = arg.gsub(/\bINTERPOLATOR_MARK\b/, "$#{args_counter}")
        args_counter += 1
        interpolated_arg
      else
        arg
      end
    end
    interpolated_sql_statement = interpolated_sql_statement_elements.join(' ')

    args[0] = interpolated_sql_statement
    interpolated_args = args.slice(1..-1)
    interpolated_sql_statement << ' RETURNING id' if should_return_id
    @returned_id = instance.exec(interpolated_sql_statement, interpolated_args)
  end

  def self.cols_exec(*args)
    args = args.join("\n")

    instance.exec(args)[0].keys
  end

  def self.last_insert_row_id
    @returned_id
  end

end
