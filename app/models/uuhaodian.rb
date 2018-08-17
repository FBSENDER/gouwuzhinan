class UuUser < ApplicationRecord
  self.table_name = 'uu_users'
end

class UuUserDetail < ApplicationRecord
  self.table_name = 'uu_user_details'
end

class UuUserGroup < ApplicationRecord
  self.table_name = 'uu_user_groups'
end

class UuUserReview < ApplicationRecord
  self.table_name = 'uu_user_reviews'
end

class WebUser < ApplicationRecord
  self.table_name = 'uu_web_users'
end

class WebUserDetail < ApplicationRecord
  self.table_name = 'uu_web_user_details'
end

class LoveUser < ApplicationRecord
  self.table_name = 'love_users'
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

class MkqBrand < ApplicationRecord
  self.table_name = 'mkq_brands'
end

class MkqCoupon < ApplicationRecord
  self.table_name = 'mkq_coupons'
end

class Banner < ApplicationRecord
  self.table_name = 'iquan_banners'
end

class Product < ApplicationRecord
  self.table_name = 'iquan_products'
end

class ProductDetail < ApplicationRecord
  self.table_name = 'iquan_product_details'
end

class ProductCoupon < ApplicationRecord
  self.table_name = 'iquan_product_coupons'
end

class Liked < ApplicationRecord
  self.table_name = 'uu_user_product_relations'
end

class MonitorProduct< ApplicationRecord
  self.table_name = 'uu_monitor_products'
end

class Video < ApplicationRecord
  self.table_name = 'iquan_videos'
end

class VideoProduct < ApplicationRecord
  self.table_name = 'iquan_video_product_relations'
end
