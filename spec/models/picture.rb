require_relative './tester'



class Picture < TesterModel
  self.table_name = 'pictures'

  belongs_to :user
  has_many :memories

  finalize!
end
