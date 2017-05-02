require_relative './tester'



class User < TesterModel
  self.table_name = 'users'

  has_many :pictures
  
  finalize!
end
