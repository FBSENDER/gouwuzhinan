class MmTopic < ApplicationRecord
  self.table_name = 'mmjpg_topics'
end

class MmTag < ApplicationRecord
  self.table_name = 'mmjpg_tags'
end

class MmSearchKeyword < ApplicationRecord
  self.table_name = 'mmjpg_search_keywords'
end
