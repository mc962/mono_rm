require_relative '../lib/model_base'


class Rider < ModelBase
  self.table_name = 'riders'

  has_many :dragons

  finalize!
end
