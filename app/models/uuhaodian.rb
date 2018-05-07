class UuUser < ApplicationRecord
  self.table_name = 'uu_users'
end

class UuToken < ApplicationRecord
  self.table_name = 'uu_tokens'
end

class ProductClick < ApplicationRecord
  self.table_name = 'iquan_product_clicks'
end

class Game < ApplicationRecord
  self.table_name = 'steam_games'
end
