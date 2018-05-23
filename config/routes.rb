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
  get "uu/goods_list", to: "uu#goods_list"
  get "uu/tb_goods_list", to: "uu#tb_goods_list"
  get "uu/sale_list", to: "uu#sale_list"
  get "uu/temai_list", to: "uu#temai_list"
  get "uu/brand_list", to: "uu#brand_list"
  get "uu/jiukuaijiu_list", to: "uu#jiukuaijiu_list"
  get "uu/category_list", to: "uu#category_list"
  get "uu/user_login", to: "uu#user_login"
  post "uu/post_message", to: "uu#post_message"
  get "uu/post_message", to: "uu#check_post_message"
  get "uu/detail_redirect/:id", to: "uu#detail_redirect"
  get "uu/inreview", to: "uu#inreview"
  get "uu/buy", to: "uu#buy"
  get "uu/game_list", to: "uu#game_list"
  get "uu/mkq_list", to: "uu#mkq_list"
  get "uu/mkq_detail", to: "uu#mkq_detail"
  get "uu/hot_keywords", to: "uu#hot_keywords"
  get "uu/banners", to: "uu#banners"

  get "jduu/collection_list", to: "jd_uu#collection_list"
  get "jduu/collection/:id", to: "jd_uu#collection"
end
