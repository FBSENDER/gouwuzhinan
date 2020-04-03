class DdkShop < ApplicationRecord
  self.table_name = 'ddk_shops'
end

class DdkShopCoupon < ApplicationRecord
  self.table_name = 'ddk_shop_coupons'
end

class DdkChannel < ApplicationRecord
  self.table_name = 'ddk_order_channels'
end

class Ddk < ApplicationRecord
  self.table_name = 'ddk_order_channels'
end

class DdkGroupProduct < ApplicationRecord
  self.table_name = 'wxgroup_pdd_products'
end

class JdCoupon < ApplicationRecord
  self.table_name = 'jd_coupons'
end

class JdChannel < ApplicationRecord
  self.table_name = 'jd_order_channels'
end
