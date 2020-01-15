class LoveQqUser < ActiveRecord::Base
  self.table_name = 'lovechecker_qq_users'
end

class LoveQqUserDetail < ActiveRecord::Base
  self.table_name = 'lovechecker_qq_user_details'
end

class Lovechecker < ActiveRecord::Base
  self.table_name = 'lovechecker_checkers'
end

class LovecheckerLog < ActiveRecord::Base
  self.table_name = 'lovechecker_checker_logs'
end
