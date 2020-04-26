class JdProduct < ApplicationRecord
  self.table_name = "zhinan_products"
end

class JdCollection < ApplicationRecord
  self.table_name = "zhinan_collections"
end

class JdCoreKeyword < ApplicationRecord
  self.table_name = 'jd_core_keywords'
end

class JdBrand < ApplicationRecord
  self.table_name = 'jd_brands'
end

class JdCategory < ApplicationRecord
  self.table_name = 'jd_categories'
end

class JdShop < ApplicationRecord
  self.table_name = 'jd_shops'
end

class JdHomeItem < ApplicationRecord
  self.table_name = 'jd_home_items'
end

class JdHomeJson < ApplicationRecord
  self.table_name = 'jd_home_jsons'
end
