class TbkArticle < ApplicationRecord
  self.table_name = 'tbk_content_articles'
end

class TbkShCategory < ApplicationRecord
  self.table_name = 'tbk_content_sh_categories'
end

class TbkShArticle < ApplicationRecord
  self.table_name = 'tbk_content_sh_article_categories'
end
