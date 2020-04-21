require 'net/http'
require 'lanlan_api' 
require 'jd_media'

class JdUuController < ApplicationController
  def collection_list
    cid = params[:cid] || 0
    page = params[:page] || 0
    cid = cid.to_i
    page = page.to_i
    if cid > 0
      @cs = JdCollection.where(category: cid, c_type: 1).select(:id, :title, :sku_img_urls, :description).order(:id).offset(20 * page).limit(20).to_a
    else
      @cs = JdCollection.where(c_type: 1).select(:id, :title, :sku_img_urls, :description).order(:id).offset(20 * page).limit(20).to_a
    end
    css = @cs.map{|c| {id: c.id, title: c.title, description: c.description, img_urls: c.sku_img_urls.split(',')}}
    render json: {status: 1001, result: css}
  end

  def collection
    @collection = JdCollection.where(id: params[:id].to_i).select(:id, :title, :description, :c_type, :sku_ids, :img_url).take
    if @collection.nil?
      render json: {status: 0}
      return
    end
    @skus = JdProduct.where(sku_id: @collection.sku_ids.split(',')).select(:id, :sku_id, :title, :description, :img_url, :ad_url, :price, :o_price).to_a
    render json: {status: 1001, result: {collection: @collection, skus: @skus}}
  end

  def core_keyword
    if params[:id].to_i == 0
      render json: {status: 0}
      return
    end
    key = Digest::MD5.hexdigest("jduucorekeyword_#{params[:id].to_i}")
    if result = $dcl.get(key)
      render json: result
      return
    end
    keyword = JdCoreKeyword.where(id: params[:id].to_i).select(:id, :keyword).take
    if keyword.nil?
      render json: {status: 0}
      return
    end
    brands = JdBrand.connection.execute("select b.name
from jd_brands b
join jd_brand_keywords bk on b.id = bk.brand_id
where bk.keyword_id = #{keyword.id}").to_a.map{|row| row[0]}
    cates = JdCategory.connection.execute("select c.name
from jd_categories c
join jd_category_keywords ck on c.id = ck.category_id
where ck.keyword_id = #{keyword.id}").to_a.map{|row| row[0]}
    shops = JdShop.connection.execute("select s.id, s.source_id, s.name
from jd_shops s
join jd_shop_keywords sk on s.id = sk.shop_Id
where sk.keyword_id = #{keyword.id}").to_a.map{|row| {id: row[0], source_id: row[1], name: row[2]}}
    related = JdCoreKeyword.where("id > ?", keyword.id).select(:id, :keyword).order(:id).limit(10)
    d_data = {status: 1, result: {id: keyword.id, keyword: keyword.keyword, brands: brands, cates: cates, shops: shops, related_keywords: related}}
    render json: d_data
    $dcl.set(key, d_data.to_json)
  end
end
