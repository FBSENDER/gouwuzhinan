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

class Shop < ApplicationRecord
  self.table_name = 'iquan_shops'
end

class ShopUrl < ApplicationRecord
  self.table_name = 'iquan_shop_urls'
end

class ShopHotItem < ApplicationRecord
  self.table_name = 'iquan_shop_hot_items'
end

class UuChannel < ApplicationRecord
  self.table_name = 'uu_order_channels'
end

class TbKeyword < ApplicationRecord
  self.table_name = 'tb_keywords'
end

class TbCategory < ApplicationRecord
  self.table_name = 'tb_categories'
end

class TbKeywordSelector < ApplicationRecord
  self.table_name = 'tb_keyword_selectors'
end

class SwanFav < ApplicationRecord
  self.table_name = 'swan_favs'
end

class SwanUuUser < ApplicationRecord
  self.table_name = 'swan_uu_users'
end

class SwanKefuClick < ApplicationRecord
  self.table_name = 'swan_kefu_clicks'
end

class QixiuProduct < ApplicationRecord
  self.table_name = 'qixiu_products'
end
class MeizhuangProduct < ApplicationRecord
  self.table_name = 'meizhuang_products'
end
class PeishiProduct < ApplicationRecord
  self.table_name = 'peishi_products'
end
class YmqProduct < ApplicationRecord
  self.table_name = 'ymq_products'
end
class CailiaoProduct < ApplicationRecord
  self.table_name = 'cailiao_products'
end
class JiankangProduct < ApplicationRecord
  self.table_name = 'jiankang_products'
end
class ShipinProduct < ApplicationRecord
  self.table_name = 'shipin_products'
end

class SwanJumpSetting < ApplicationRecord
  self.table_name = 'swan_jump_settings'
end

class SwanApp < ApplicationRecord
  self.table_name = 'swan_apps'
end

class SwanShenheIp < ApplicationRecord
  self.table_name = 'swan_shenhe_ips'
end
class QixiuGoodKeyword < ApplicationRecord
  self.table_name = 'qixiu_good_keywords'
end

class DtkBrand < ApplicationRecord
  self.table_name = 'dataoke_brands'
end

class DtkBrandProduct < ApplicationRecord
  self.table_name = 'dataoke_brand_products'
end

class DtkCategory < ApplicationRecord
  self.table_name = 'dataoke_categories'
end

class DtkBcr < ApplicationRecord
  self.table_name = 'dataoke_brand_category_relations'
end

class DtkProduct < ApplicationRecord
  self.table_name = 'dataoke_products'
end

class DtkShopSeo < ApplicationRecord
  self.table_name = 'dataoke_shop_seo_jsons'
end

class JishiKeyword < ApplicationRecord
  self.table_name = 'jishi_keywords'
end

class WxgroupShareProduct < ApplicationRecord
  self.table_name = 'wxgroup_share_products'
end

class ZhinanJdStaticProduct < ApplicationRecord
  self.table_name = 'zhinan_jd_static_products'
end

class ZhinanJdStaticEnProduct < ApplicationRecord
  self.table_name = 'zhinan_jd_static_en_products'
end

class ZhinanJdEnKeyword < ApplicationRecord
  self.table_name = 'zhinan_jd_en_keywords'
end

class ZhinanJdFxhhEnProduct < ApplicationRecord
  self.table_name = 'zhinan_jd_fxhh_en_products'
end

class ZhinanJdEnKpRelation < ApplicationRecord
  self.table_name = 'zhinan_jd_en_keyword_product_relations'
end

class UuArticle < ApplicationRecord
  self.table_name = 'uu_articles'
end

class UuArticleTag < ApplicationRecord
  self.table_name = 'uu_article_tags'
end

class UuArticleTagRelation < ApplicationRecord
  self.table_name = 'uu_article_tag_relations'
end

class UuAiContent < ApplicationRecord
  self.table_name = 'uu_ai_contents'
end
