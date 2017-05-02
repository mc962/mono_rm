require_relative './tester'



class Memory < TesterModel
  self.table_name = 'memories'

  belongs_to :picture
  has_one :user, through: :picture

  finalize!
end
