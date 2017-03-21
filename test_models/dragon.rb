require_relative '../lib/model_base'
require_relative './rider'

class Dragon < ModelBase
  self.table_name = 'dragons'
  belongs_to :rider
  has_many :memories

  finalize!
end
