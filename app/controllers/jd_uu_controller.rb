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
end
