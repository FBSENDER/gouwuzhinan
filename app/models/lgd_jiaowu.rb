class LgdWxUser < ApplicationRecord
  self.table_name = 'lgd_wx_users'
end
class LgdJiaowuUser < ApplicationRecord
  self.table_name = 'lgd_jiaowu_users'
end
class LgdWjUserRelation < ApplicationRecord
  self.table_name = 'lgd_wx_jiaowu_user_relations'
end
class LgdStudent < ApplicationRecord
  self.table_name = 'lgd_students'
end
class LgdScore < ApplicationRecord
  self.table_name = "lgd_jiaowu_scores"
end
class LgdCet < ApplicationRecord
  self.table_name = "lgd_jiaowu_cets"
end
class LgdExam < ApplicationRecord
  self.table_name = "lgd_jiaowu_exams"
end
class LgdClass < ApplicationRecord
  self.table_name = "lgd_jiaowu_classes"
end
class LgdDoc < ApplicationRecord
  self.table_name = 'lgd_jiaowu_docs'
end
