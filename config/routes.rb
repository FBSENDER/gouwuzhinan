Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "/", to: "uu#home", constraints: {host: 'api.uuhaodian.com'}
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
  get "uu/product_qixiu", to: "uu#product_qixiu"
  get "uu/product_meizhuang", to: "uu#product_meizhuang"
  get "uu/product_peishi", to: "uu#product_peishi"
  get "uu/product_yumaoqiu", to: "uu#product_yumaoqiu"
  get "uu/product_cailiao", to: "uu#product_cailiao"
  get "uu/product_shipin", to: "uu#product_shipin"
  get "uu/product_jiankang", to: "uu#product_jiankang"
  get "uu/goods_list", to: "uu#goods_list"
  get "uu/dg_goods_list", to: "uu#dg_goods_list"
  get "uu/dg_seo_goods_list", to: "uu#dg_seo_goods_list"
  get "uu/tb_goods_list", to: "uu#tb_goods_list"
  get "uu/tb_goods_item_list", to: "uu#tb_goods_item_list"
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
  post "uu/bd_post_message", to: "uu#check_post_message"
  get "uu/post_message", to: "uu#check_post_message"
  get "uu/gzh_reply", to: "uu#check_post_message"
  get "uu/detail_redirect/:id", to: "uu#detail_redirect"
  get "uu/inreview", to: "uu#inreview"
  get "uu/buy", to: "uu#buy"
  get "uu/pcbuy", to: "uu#pcbuy"
  get "uu/newbuy", to: "uu#newbuy"
  get "uu/buy_kouling", to: "uu#buy_kouling"
  get "uu/game_list", to: "uu#game_list"
  get "uu/mkq_list", to: "uu#mkq_list"
  get "uu/mkq_detail", to: "uu#mkq_detail"
  get "uu/hot_keywords", to: "uu#hot_keywords"
  get "uu/hot_keywords_new", to: "uu#hot_keywords_new"
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
  get "uu/shop", to: "uu#shop"
  get "uu/shop_go", to: "uu#shop_go"
  get "uu/shop_hot_items", to: "uu#shop_hot_items"
  get "uu/keyword_infos", to: "uu#keyword_infos"
  get "uu/jishi_keywords", to: "uu#jishi_keywords"
  get "uu/swan_fav_add", to: "uu#swan_fav_add"
  get "uu/swan_fav_del", to: "uu#swan_fav_del"
  get "uu/swan_uu_login", to: "uu#swan_uu_login"
  get "uu/swan_kefu_click", to: "uu#swan_kefu_click"
  get "uu/g/:id", to: "uu#swan_kefu_go"
  get "uu/xcx_kmap", to: "uu#xcx_kmap"
  get "uu/swan_jump", to: "uu#swan_jump"
  get "uu/swan_in_sh", to: "uu#swan_in_sh"
  get "uu/swan_is_in_sh", to: "uu#swan_is_in_sh"
  get "uu/qixiu_good_keyword", to: "uu#qixiu_good_keyword"
  get "uu/group_products", to: "uu#group_products"
  get "uu/query_suggest", to: "uu#query_suggest"
  get "uu/xiaohui_app", to: "uu#xiaohui_app"
  get "uu/a_content", to: "uu#a_content"
  get "uu/agents_coupon_query", to: "uu#agents_coupon_query"

  #uu_article
  get "uu/article", to: "uu#article"
  get "uu/article_list", to: "uu#article_list"

  #dtk
  get "uu/dtk_categories", to: "uu#dtk_categories"
  get "uu/dtk_category_goods", to: "uu#dtk_category_goods"
  get "uu/dtk_category_new_goods", to: "uu#dtk_category_new_goods"
  get "uu/dtk_topics", to: "uu#dtk_topics"
  get "uu/dtk_ranks", to: "uu#dtk_ranks"
  get "uu/dtk_topic_goods", to: "uu#dtk_topic_goods"
  get "uu/dtk_brands", to: "uu#dtk_brands"
  get "uu/dtk_brand_detail", to: "uu#dtk_brand_detail"
  get "uu/dtk_brand_goods", to: "uu#dtk_brand_goods"
  get "uu/dtk_product", to: "uu#dtk_product"
  get "uu/dtk_product_sitemap", to: "uu#dtk_product_sitemap"
  get "uu/dtk_static_product", to: "uu#dtk_static_product"
  get "uu/dtk_search_normal", to: "uu#dtk_search_normal"
  get "uu/dtk_shop_convert", to: "uu#dtk_shop_convert"
  get "uu/dtk_shop_seo", to: "uu#dtk_shop_seo"

  get "love/user_login", to: "love#user_login"
  post "love/user_info", to: "love#user_info"

  get "jduu/collection_list", to: "jd_uu#collection_list"
  get "jduu/collection/:id", to: "jd_uu#collection"
  get "jduu/core_keyword", to: "jd_uu#core_keyword"
  get "jduu/search_by_keyword", to: "jd_uu#search_by_keyword"
  get "jduu/search_by_cat1", to: "jd_uu#search_by_cat1"
  get "jduu/search_by_cat3", to: "jd_uu#search_by_cat3"
  get "jduu/search_by_shop", to: "jd_uu#search_by_shop"
  get "jduu/search_by_ids", to: "jd_uu#search_by_ids"
  get "jduu/search_by_brand", to: "jd_uu#search_by_brand"
  get "jduu/product", to: "jd_uu#product"
  get "jduu/product_url", to: "jd_uu#product_url"
  get "jduu/trans_diy_url", to: "jd_uu#trans_diy_url"
  get "jduu/jd_home_items", to: "jd_uu#jd_home_items"
  get "jduu/jd_home_json", to: "jd_uu#jd_home_json"
  get "jduu/jd_home_coupons", to: "jd_uu#jd_home_coupons"
  get "jduu/jd_shop_json", to: "jd_uu#jd_shop_json"
  get "jduu/jd_shop_seo_json", to: "jd_uu#jd_shop_seo_json"
  get "jduu/jd_shop_home_list", to: "jd_uu#jd_shop_home_list"
  get "jduu/jd_shop_all_cate", to: "jd_uu#jd_shop_all_cate"
  get "jduu/jd_shop_seo_list_by_cate", to: "jd_uu#jd_shop_seo_list_by_cate"
  get "jduu/jd_shop_seo_list_by_cate_ziying", to: "jd_uu#jd_shop_seo_list_by_cate_ziying"
  get "jduu/new_jd_shop_seo_json_list", to: "jd_uu#new_jd_shop_seo_json_list"
  get "jduu/home_page_json", to: "jd_uu#home_page_json"
  get "jduu/new_zhinan_jd_static_product_keyword_list", to: "jd_uu#new_zhinan_jd_static_product_keyword_list"
  get "jduu/new_zhinan_jd_static_product_list", to: "jd_uu#new_zhinan_jd_static_product_list"
  get "jduu/zhinan_jd_static_products", to: "jd_uu#zhinan_jd_static_products"
  post "jduu/zhinan_jd_static_product_like", to: "jd_uu#zhinan_jd_static_product_like"
  get "jduu/zhinan_jd_static_en_products", to: "jd_uu#zhinan_jd_static_en_products"
  get "jduu/zhinan_jd_en_keyword_1", to: "jd_uu#zhinan_jd_en_keyword_1"
  get "jduu/zhinan_jd_en_keyword_2", to: "jd_uu#zhinan_jd_en_keyword_2"
  get "jduu/jd_seo_data", to: "jd_uu#jd_seo_data"
  get "jduu/jd_open_search", to: "jd_uu#jd_open_search"

  get "ddk/search", to: "ddk#search"
  get "ddk/search_2", to: "ddk#search_2"
  get "ddk/product", to: "ddk#goods_detail"
  get "ddk/wx_qrcode", to: "ddk#get_wx_qrcode"
  get "ddk/wx_qrcode_new", to: "ddk#get_wx_qrcode_new"
  get "ddk/promotion_url", to: "ddk#get_promotion_url"
  get "ddk/promotion_url_new", to: "ddk#get_promotion_url_new"
  get "ddk/mall_url", to: "ddk#get_mall_url"
  get "ddk/hot_list", to: "ddk#hot_list"
  get "ddk/rec_list", to: "ddk#rec_list"
  get "ddk/theme_list", to: "ddk#theme_list"
  get "ddk/theme_detail", to: "ddk#theme_detail"
  get "ddk/mall_info", to: "ddk#mall_info"
  get "ddk/mall_products", to: "ddk#mall_products"
  get "ddk/group_products", to: "ddk#group_products"
  get "ddk/mall_list", to: "ddk#mall_list"
  get "ddk/opt_list", to: "ddk#get_opt_list"
  get "ddk/opt_products", to: "ddk#get_opt_products"
  get "ddk/jd_search", to: "ddk#jd_search"
  get "ddk/jd_cat_products", to: "ddk#jd_cat_products"
  get "ddk/jd_mall_products", to: "ddk#jd_mall_products"
  get "ddk/jd_product", to: "ddk#jd_product"
  get "ddk/jd_product_url", to: "ddk#jd_product_url"
  get "ddk/jd_coupons", to: "ddk#jd_coupons"
  get "ddk/jd_miaosha", to: "ddk#jd_miaosha"
  get "ddk/authority_query", to: "ddk#authority_query"
  get "ddk/authority_generate", to: "ddk#authority_generate"

  post "lgd/jiaowu/wx_login", to: "lgd#wx_login"
  post "lgd/jiaowu/jiaowu_login", to: "lgd#jiaowu_login"
  post "lgd/jiaowu/jiaowu_logout", to: "lgd#jiaowu_logout"
  post "lgd/jiaowu/swan_login", to: "lgd#swan_login"
  post "lgd/jiaowu/swan_jiaowu_login", to: "lgd#swan_jiaowu_login"
  post "lgd/jiaowu/swan_jiaowu_logout", to: "lgd#swan_jiaowu_logout"
  post "lgd/jiaowu/qq_open_id", to: "lgd#qq_open_id"
  post "lgd/jiaowu/qq_login", to: "lgd#qq_login"
  post "lgd/jiaowu/qq_jiaowu_login", to: "lgd#qq_jiaowu_login"
  post "lgd/jiaowu/qq_jiaowu_logout", to: "lgd#qq_jiaowu_logout"
  post "lgd/jiaowu/jiaowu_sync", to: "lgd#jiaowu_sync"
  get "lgd/jiaowu/jiaowu_user", to: "lgd#jiaowu_user"
  get "lgd/jiaowu/scores", to: "lgd#jiaowu_scores"
  get "lgd/jiaowu/cets", to: "lgd#jiaowu_cets"
  get "lgd/jiaowu/exams", to: "lgd#jiaowu_exams"
  get "lgd/jiaowu/classes", to: "lgd#jiaowu_classes"
  get "lgd/jiaowu/docs", to: "lgd#jiaowu_docs"
  get "lgd/jiaowu/doc", to: "lgd#jiaowu_doc"
  get "lgd/jiaowu/notices", to: "lgd#jiaowu_notices"
  get "lgd/jiaowu/notice", to: "lgd#jiaowu_notice"

  get "yealink/users", to: "yealink#users"

  get "content/sh/home_list", to: "content#sh_home_list"
  get "content/sh/new_list", to: "content#sh_new_list"
  get "content/sh/related_list", to: "content#sh_related_list"

  #lovechecker 
  post "lovechecker/qq_login", to: "lovechecker#qq_login"
  post "lovechecker/set_gender", to: "lovechecker#set_gender"
  post "lovechecker/update_user_detail", to: "lovechecker#update_user_detail"
  post "lovechecker/send_checker", to: "lovechecker#send_checker"
  post "lovechecker/delete_checker", to: "lovechecker#delete_checker"
  post "lovechecker/reply_checker", to: "lovechecker#reply_checker"
  get "lovechecker/get_checker", to: "lovechecker#get_checker"
  get "lovechecker/get_man_checker", to: "lovechecker#get_man_checker"
  post "lovechecker/check_status", to: "lovechecker#check_status"
  get "lovechecker/checker_need_reply", to: "lovechecker#checker_need_reply"

  #wxgroup
  post "wxgroup/user_login", to: "wxgroup#user_login"
  post "wxgroup/update_user_detail", to: "wxgroup#update_user_detail"
  post "wxgroup/add_group", to: "wxgroup#add_group"
  post "wxgroup/group_register", to: "wxgroup#group_register"
  post "wxgroup/group_register_remove", to: "wxgroup#group_register_remove"
  get "wxgroup/group_list", to: "wxgroup#group_list"
  get "wxgroup/group_users", to: "wxgroup#group_users"
  post "wxgroup/add_task", to: "wxgroup#add_task"
  post "wxgroup/end_task", to: "wxgroup#end_task"
  get "wxgroup/task_list", to: "wxgroup#task_list"
  get "wxgroup/task_users", to: "wxgroup#task_users"
  get "wxgroup/task_detail", to: "wxgroup#task_detail"
  get "wxgroup/task_refresh_money", to: "wxgroup#task_refresh_money"
  get "wxgroup/task_refresh_bang", to: "wxgroup#task_refresh_bang"
  get "wxgroup/is_user_in_task", to: "wxgroup#is_user_in_task"
  post "wxgroup/user_in_task", to: "wxgroup#user_in_task"
  post "wxgroup/user_done_task", to: "wxgroup#user_done_task"
  post "wxgroup/user_share_task", to: "wxgroup#user_share_task"
  post "wxgroup/add_group_product", to: "wxgroup#add_group_product"
  post "wxgroup/add_share_record", to: "wxgroup#add_share_record"

  #fahuo
  post "fahuo/swan_user_login", to: "fahuo#swan_user_login"
  post "fahuo/swan_user_detail", to: "fahuo#swan_user_detail"
  post "fahuo/new_review", to: "fahuo#new_review"
  get "fahuo/shop_reviews", to: "fahuo#shop_reviews"
  get "fahuo/shop_list", to: "fahuo#shop_list"

  #guancha
  get "guancha/t1", to: "guancha#table_style_1"

  #twitter
  get "twitter/jianguo", to: "twitter#jianguo"
  get "twitter/jianguo_search", to: "twitter#jianguo_search"
  
end
