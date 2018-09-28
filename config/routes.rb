Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "jd_media#collection_home"
  get "collection/:id", to: "jd_media#collection"
  get "cc/:id", to: "jd_media#collection_category"
  get "jdsku/:id", to: "jd_media#jdsku"
  get "tj/:wx_id/", to: "tj#tj"
  get "tjp/:wx_id/", to: "tj#tj_point"

  get "topic/:id", to: "topic#show"
  get "topictest", to: "topic#show_1"

  get "gpost/:id", to: "guang#gpost_show"

  get "mm/topic/:id", to: "mm#topic"
  get "mm/tag/:tag", to: "mm#tag"
  get "mm/hot_tags", to: "mm#hot_tags"
  get "mm/search/", to: "mm#search"
  get "mm/search/:keyword", to: "mm#search"
  get "mm/collect/:ids", to: "mm#collect"
  get "mm/new", to: "mm#new"
  get "mm/hot", to: "mm#hot"
  get "mm/app_init_config", to: "mm#app_init_config"
  get "mm/app_feedback", to: "mm#app_feedback"

  get "uu/home_list", to: "uu#home_list"
  get "uu/product", to: "uu#product"
  get "uu/product_db", to: "uu#product_db"
  get "uu/product_tb", to: "uu#product_tb"
  get "uu/product_tbs", to: "uu#product_tbs"
  get "uu/goods_list", to: "uu#goods_list"
  get "uu/tb_goods_list", to: "uu#tb_goods_list"
  get "uu/tb_goods_recommend", to: "uu#tb_goods_recommend"
  get "uu/tb_dg_list", to: "uu#tb_dg_list"
  get "uu/sale_list", to: "uu#sale_list"
  get "uu/temai_list", to: "uu#temai_list"
  get "uu/brand_list", to: "uu#brand_list"
  get "uu/jiukuaijiu_list", to: "uu#jiukuaijiu_list"
  get "uu/category_list", to: "uu#category_list"
  get "uu/user_login", to: "uu#user_login"
  get "uu/user_group", to: "uu#user_group"
  get "uu/get_my_groups", to: "uu#get_my_groups"
  get "uu/get_group_detail", to: "uu#get_group_detail"
  get "uu/add_user_info", to: "uu#add_user_info"
  get "uu/get_user_info", to: "uu#get_user_info"
  get "uu/add_user_score", to: "uu#add_user_score"
  get "uu/add_user_review", to: "uu#add_user_review"
  get "uu/user_review_reply", to: "uu#user_review_reply"
  get "uu/get_user_review", to: "uu#get_user_review"
  post "uu/post_message", to: "uu#post_message"
  post "uu/gzh_reply", to: "uu#gzh_reply"
  get "uu/post_message", to: "uu#check_post_message"
  get "uu/gzh_reply", to: "uu#check_post_message"
  get "uu/detail_redirect/:id", to: "uu#detail_redirect"
  get "uu/inreview", to: "uu#inreview"
  get "uu/buy", to: "uu#buy"
  get "uu/pcbuy", to: "uu#pcbuy"
  get "uu/game_list", to: "uu#game_list"
  get "uu/mkq_list", to: "uu#mkq_list"
  get "uu/mkq_detail", to: "uu#mkq_detail"
  get "uu/hot_keywords", to: "uu#hot_keywords"
  get "uu/banners", to: "uu#banners"
  get "uu/create_tbwd", to: "uu#create_tbwd"
  get "uu/query_tbwd", to: "uu#query_tbwd"
  get "uu/check_product_liked", to: "uu#check_product_liked"
  get "uu/get_product_liked", to: "uu#get_product_liked"
  get "uu/add_product_liked", to: "uu#add_product_liked"
  get "uu/cancel_product_liked", to: "uu#cancel_product_liked"
  get "uu/web_login", to: "uu#web_login"
  get "uu/web_logout", to: "uu#web_logout"
  get "uu/video_list", to: "uu#video_list"
  get "uu/video", to: "uu#video"

  get "love/user_login", to: "love#user_login"
  post "love/user_info", to: "love#user_info"

  get "jduu/collection_list", to: "jd_uu#collection_list"
  get "jduu/collection/:id", to: "jd_uu#collection"

  get "ddk/search", to: "ddk#search"
  get "ddk/product", to: "ddk#goods_detail"
  get "ddk/wx_qrcode", to: "ddk#get_wx_qrcode"
  get "ddk/promotion_url", to: "ddk#get_promotion_url"

end
