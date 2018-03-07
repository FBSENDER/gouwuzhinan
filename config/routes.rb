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
end
