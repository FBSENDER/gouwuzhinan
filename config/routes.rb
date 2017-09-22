Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "jd_media#collection_home"
  get "collection/:id", to: "jd_media#collection"
  get "cc/:id", to: "jd_media#collection_category"
  get "jdsku/:id", to: "jd_media#jdsku"
  get "tj/:wx_id/", to: "tj#tj"
  get "tjp/:wx_id/", to: "tj#tj_point"

  get "mm/topic/:id", to: "mm#topic"
  get "mm/tag/:tag", to: "mm#tag"
  get "mm/hot_tags", to: "mm#hot_tags"
end
