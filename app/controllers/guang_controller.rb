require 'guang'
class GuangController < ApplicationController
  def gpost_show
    @post = GuangPost.where(id: params[:id].to_i).take
    not_found if @post.nil? || @post.type_id != 2
    @products = GuangProduct.where(item_id: @post.item_ids.split(',')).select(:item_id, :title, :price, :origin_price, :pic_url).to_a

    @related_posts = GuangPost.where("id > ? and type_id = 2", @post.id).select(:id, :title).order(:id).limit(5)
    @path = "/gpost/#{@post.id}/"
    json_ld = {}
    json_ld["@context"] = "https://ziyuan.baidu.com/contexts/cambrian.jsonld"
    json_ld["@id"] = "http://www.gouwuzhinan.cn#{@path}"
    json_ld["appid"] = 1583226250921762
    json_ld["title"] = @post.title
    json_ld["images"] = @products.map{|c| c["pic_url"]}[0,3]
    json_ld["description"] = "#{@post.description} - #{@post.title}"
    json_ld["pubDate"] = @post.created_at.strftime("%FT%T")
    @json_ld = json_ld.to_json
    render "mip/guang/gpost_show", layout: "xiongzhang"
  end
end
