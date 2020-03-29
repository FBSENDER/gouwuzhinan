class WxgroupUser < ApplicationRecord
  self.table_name = 'wxgroup_users'
end

class WxgroupUserDetail < ApplicationRecord
  self.table_name = 'wxgroup_user_details'
end

class Wxgroup < ApplicationRecord
  self.table_name = 'wxgroup_groups'
end

class WxgroupRegister < ApplicationRecord
  self.table_name = 'wxgroup_registers'
end

class WxgroupTask < ApplicationRecord
  self.table_name = 'wxgroup_tasks'
end

class WxgroupTaskUser < ApplicationRecord
  self.table_name = 'wxgroup_task_users'
end

class WxgroupShareLog < ApplicationRecord
  self.table_name = 'wxgroup_share_logs'
end

class WxgroupPddProduct < ApplicationRecord
  self.table_name = 'wxgroup_pdd_products'
end

class WxgroupShareRecord < ApplicationRecord
  self.table_name = 'wxgroup_share_records'
end
