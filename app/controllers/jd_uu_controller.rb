require "digest/md5"
require 'net/http'
require "json"
require 'ddk'
require 'lanlan_api' 
require 'jdk_api'
require 'jd_media'

class JdUuController < ApplicationController
  skip_before_action :verify_authenticity_token
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

  def product
    begin
      if params[:id].nil? || params[:id].to_i <= 0
        render json: {status: 0}
        return 
      end
      id = [params[:id].to_i]
      key = Digest::MD5.hexdigest("jduuproduct_#{params[:id].to_i}")
      if result = $dcl.get(key)
        render json: result
        return
      end
      r = jd_union_open_goods_query(1, 20, nil, nil, nil, nil, id, nil, nil, nil, nil, nil, nil, nil, nil)
      data = do_with_search_result_product(JSON.parse(r))
      render json: data
      $dcl.set(key, data.to_json) if data[:status] == 200
    rescue
      render json: {status: 0}
    end
  end

  def search_by_cat1
    begin
      page = params[:page].nil? || params[:page].to_i <= 0 ? 1 : params[:page].to_i
      cid1 = params[:cid1]
      owner = params[:owner]
      sort_name = params[:sort_name]
      sort = "desc"
      if sort_name == "price_asc"
        sort_name = 'price'
        sort = 'asc'
      elsif sort_name == "price_desc"
        sort_name = 'price'
        sort = 'desc'
      end
      is_hot = params[:is_hot]
      is_coupon = params[:has_coupon]
      key = Digest::MD5.hexdigest("jduusearchbycat1_#{cid1}_#{page}_#{owner}_#{sort_name}_#{sort}_#{is_hot}_#{is_coupon}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      r = jd_union_open_goods_query(page, 20, nil, cid1, nil, nil, nil, owner, sort_name, sort, is_coupon, nil, is_hot, nil, nil)
      data = do_with_search_result_query(JSON.parse(r))
      render json: data, callback: params[:callback]
      $dcl.set(key, data.to_json) if data[:status] == 200
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def search_by_cat3
    begin
      page = params[:page].nil? || params[:page].to_i <= 0 ? 1 : params[:page].to_i
      cid3 = params[:cid3]
      owner = params[:owner]
      sort_name = params[:sort_name]
      sort = "desc"
      if sort_name == "price_asc"
        sort_name = 'price'
        sort = 'asc'
      elsif sort_name == "price_desc"
        sort_name = 'price'
        sort = 'desc'
      end
      is_hot = params[:is_hot]
      is_coupon = params[:has_coupon]
      key = Digest::MD5.hexdigest("jduusearchbycat3_#{cid3}_#{page}_#{owner}_#{sort_name}_#{sort}_#{is_hot}_#{is_coupon}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      r = jd_union_open_goods_query(page, 20, nil, nil, nil, cid3, nil, owner, sort_name, sort, is_coupon, nil, is_hot, nil, nil)
      data = do_with_search_result_query(JSON.parse(r))
      render json: data, callback: params[:callback]
      $dcl.set(key, data.to_json) if data[:status] == 200
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def search_by_shop
    begin
      page = params[:page].nil? || params[:page].to_i <= 0 ? 1 : params[:page].to_i
      shop_id = params[:shop_id].to_i
      cid3 = params[:cid3]
      owner = params[:owner]
      sort_name = params[:sort_name]
      sort = "desc"
      if sort_name == "price_asc"
        sort_name = 'price'
        sort = 'asc'
      elsif sort_name == "price_desc"
        sort_name = 'price'
        sort = 'desc'
      end
      is_hot = params[:is_hot]
      is_coupon = params[:has_coupon]
      key = Digest::MD5.hexdigest("jduusearchbyshop_#{shop_id}_#{page}_#{cid3}_#{owner}_#{sort_name}_#{sort}_#{is_hot}_#{is_coupon}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      r = jd_union_open_goods_query(page, 20, nil, nil, nil, cid3, nil, owner, sort_name, sort, is_coupon, nil, is_hot, shop_id, nil)
      data = do_with_search_result_query(JSON.parse(r))
      render json: data, callback: params[:callback]
      $dcl.set(key, data.to_json) if data[:status] == 200
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def search_by_brand
    begin
      page = params[:page].nil? || params[:page].to_i <= 0 ? 1 : params[:page].to_i
      brand_id = params[:brand_id]
      cid3 = params[:cid3]
      owner = params[:owner]
      sort_name = params[:sort_name]
      sort = "desc"
      if sort_name == "price_asc"
        sort_name = 'price'
        sort = 'asc'
      elsif sort_name == "price_desc"
        sort_name = 'price'
        sort = 'desc'
      end
      is_hot = params[:is_hot]
      is_coupon = params[:has_coupon]
      key = Digest::MD5.hexdigest("jduusearchbybrand_#{brand_id}_#{page}_#{cid3}_#{owner}_#{sort_name}_#{sort}_#{is_hot}_#{is_coupon}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      r = jd_union_open_goods_query(page, 20, nil, nil, nil, cid3, nil, owner, sort_name, sort, is_coupon, nil, is_hot, nil, brand_id)
      data = do_with_search_result_query(JSON.parse(r))
      render json: data, callback: params[:callback]
      $dcl.set(key, data.to_json) if data[:status] == 200
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def search_by_ids
    begin
      page = params[:page].nil? || params[:page].to_i <= 0 ? 1 : params[:page].to_i
      ids = params[:ids].strip.split(',')
      key = Digest::MD5.hexdigest("jduusearchbyids_#{ids.join(',')}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      r = jd_union_open_goods_query(page, 20, nil, nil, nil, nil, ids, nil, nil, nil, nil, nil, nil, nil, nil)
      data = do_with_search_result_query(JSON.parse(r))
      render json: data, callback: params[:callback]
      $dcl.set(key, data.to_json) if data[:status] == 200
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end
  def search_by_keyword
    begin
      page = params[:page].nil? || params[:page].to_i <= 0 ? 1 : params[:page].to_i
      keyword = params[:keyword].strip
      cid3 = params[:cid3]
      owner = params[:owner]
      sort_name = params[:sort_name]
      sort = "desc"
      if sort_name == "price_asc"
        sort_name = 'price'
        sort = 'asc'
      elsif sort_name == "price_desc"
        sort_name = 'price'
        sort = 'desc'
      end
      is_hot = params[:is_hot]
      is_coupon = params[:has_coupon]
      key = Digest::MD5.hexdigest("jduusearchbykeyword_#{keyword}_#{page}_#{cid3}_#{owner}_#{sort_name}_#{sort}_#{is_hot}_#{is_coupon}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      #(page, page_size, keyword, cid1, cid2, cid3, sku_ids, owner, sort_name, sort, is_coupon, is_pg, is_hot, shop_id, brand_code)
      r = jd_union_open_goods_query(page, 20, keyword, nil, nil, cid3, nil, owner, sort_name, sort, is_coupon, nil, is_hot, nil, nil)
      data = do_with_search_result_query(JSON.parse(r))
      render json: data, callback: params[:callback]
      $dcl.set(key, data.to_json) if data[:status] == 200
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def do_with_search_result_query(r)
    begin
      rr = r["jd_union_open_goods_query_response"]["result"]
      result = JSON.parse(rr)
      if result["code"] == 200 && result["data"] && result["data"].size > 0
        total = result["totalCount"] ? result["totalCount"].to_i : 0
        results = []
        result["data"].each do |d|
          item = {
            item_id: d["skuId"],
            title: d["skuName"],
            pict_url: d["imageInfo"]["imageList"][0]["url"],
            sales: d["inOrderCount30Days"],
            o_price: d["priceInfo"]["price"],
            lowest_price: d["priceInfo"]["lowestPrice"],
            lowest_coupon_price: d["priceInfo"]["lowestPrice"],
            price_type: d["priceInfo"]["lowestPriceType"],
            shop_id: d["shopInfo"]["shopId"],
            shop_title: d["shopInfo"]["shopName"],
            is_hot: d["isHot"],
            owner: d["owner"],
            brand_code: d["brandCode"],
            brand_name: d["brandName"],
            cid1: d["categoryInfo"]["cid1"],
            cid2: d["categoryInfo"]["cid2"],
            cid3: d["categoryInfo"]["cid3"],
            cname1: d["categoryInfo"]["cid1Name"],
            cname2: d["categoryInfo"]["cid2Name"],
            cname3: d["categoryInfo"]["cid3Name"],
            coupon_amount: 0,
            coupon_url: "",
            coupon_quota: 0,
            coupon_type: 0
          }
          if d["couponInfo"]["couponList"].size > 0
            item[:coupon_amount] = d["couponInfo"]["couponList"][0]["discount"].to_i
            item[:coupon_url] = d["couponInfo"]["couponList"][0]["link"]
            item[:coupon_quota] = d["couponInfo"]["couponList"][0]["quota"].to_i
            item[:coupon_type] = d["couponInfo"]["couponList"][0]["bindType"]
            item[:lowest_coupon_price] = (item[:lowest_price] - d["couponInfo"]["couponList"][0]["discount"].to_i).round(2)
            d["couponInfo"]["couponList"].each do |c|
              if c["isBest"] == 1
                item[:coupon_amount] = c["discount"].to_i
                item[:coupon_url] = c["link"]
                item[:coupon_quota] = c["quota"].to_i
                item[:coupon_type] = c["bindType"]
                item[:lowest_coupon_price] = (item[:lowest_price] - c["discount"].to_i).round(2)
              end
            end
          end
          results << item
        end
        return {status: 200, results: results}
      else
        return {status: 0}
      end
    rescue
      return {status: 0}
    end
  end

  def do_with_search_result_product(r)
    begin
      rr = r["jd_union_open_goods_query_response"]["result"]
      result = JSON.parse(rr)
      if result["code"] == 200 && result["data"] && result["data"].size > 0
        d = result["data"][0]
        item = {
          item_id: d["skuId"],
          title: d["skuName"],
          pict_url: d["imageInfo"]["imageList"][0]["url"],
          images: d["imageInfo"]["imageList"].map{|m| m["url"]},
          sales: d["inOrderCount30Days"],
          comments: d["comments"],
          good_share: d["goodCommentsShare"],
          product_url: d["materialUrl"],
          o_price: d["priceInfo"]["price"],
          lowest_price: d["priceInfo"]["lowestPrice"],
          lowest_coupon_price: d["priceInfo"]["lowestPrice"],
          price_type: d["priceInfo"]["lowestPriceType"],
          shop_id: d["shopInfo"]["shopId"],
          shop_title: d["shopInfo"]["shopName"],
          is_hot: d["isHot"],
          owner: d["owner"],
          brand_code: d["brandCode"],
          brand_name: d["brandName"],
          cid1: d["categoryInfo"]["cid1"],
          cid2: d["categoryInfo"]["cid2"],
          cid3: d["categoryInfo"]["cid3"],
          cname1: d["categoryInfo"]["cid1Name"],
          cname2: d["categoryInfo"]["cid2Name"],
          cname3: d["categoryInfo"]["cid3Name"],
          coupon_amount: 0,
          coupon_url: "",
          coupon_quota: 0,
          coupon_type: 0,
          end_time: 0
        }
        if d["couponInfo"]["couponList"].size > 0
          item[:coupon_amount] = d["couponInfo"]["couponList"][0]["discount"].to_i
          item[:coupon_url] = d["couponInfo"]["couponList"][0]["link"]
          item[:coupon_quota] = d["couponInfo"]["couponList"][0]["quota"].to_i
          item[:coupon_type] = d["couponInfo"]["couponList"][0]["bindType"]
          item[:end_time] = d["couponInfo"]["couponList"][0]["useEndTime"] / 1000
          item[:lowest_coupon_price] = (item[:lowest_price] - d["couponInfo"]["couponList"][0]["discount"].to_i).round(2)
          d["couponInfo"]["couponList"].each do |c|
            if c["isBest"] == 1
              item[:coupon_amount] = c["discount"].to_i
              item[:coupon_url] = c["link"]
              item[:coupon_quota] = c["quota"].to_i
              item[:coupon_type] = c["bindType"]
              item[:end_time] = c["useEndTime"] / 1000
              item[:lowest_coupon_price] = (item[:lowest_price] - c["discount"].to_i).round(2)
            end
          end
        end
        return {status: 200, result: item}
      else
        return {status: 0}
      end
    rescue
      return {status: 0}
    end
  end

  def product_url
    begin
      id = params[:id].to_i
      jd_channel = params[:jd_channel].nil? ? 0 : params[:jd_channel].to_i
      key = Digest::MD5.hexdigest("jduuproducturl_#{id}_#{jd_channel}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      positionid = $default_jd_position_id
      if c = get_jd_channel
        positionid = c.source_id
      end
      r = JSON.parse(jd_union_open_promotion_bysubunionid_get(id, positionid, params[:coupon]))
      data = do_with_product_url(r)
      render json: data, callback: params[:callback]
      $dcl.set(key, data.to_json) if data[:status] == 200
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def get_jd_channel
    if params[:jd_channel].nil?
      return nil
    end
    if $jd_channels.nil? || (Time.now.to_i - $jd_channels_update) > 3600
      $jd_channels = JdChannel.all.to_a
      $jd_channels_update = Time.now.to_i
    end
    $jd_channels.each do |c|
      return c if c.id == params[:jd_channel].to_i
    end
    nil
  end

  def do_with_product_url(r)
    begin
      rr = r["jd_union_open_promotion_bysubunionid_get_response"]["result"]
      result = JSON.parse(rr)
      if result["code"] == 200 && result["data"] && result["data"]["shortURL"]
        return {status: 200, data: result["data"]["shortURL"]}
      else
        return {status: 0}
      end
    rescue
      return {status: 0}
    end
  end

  def trans_diy_url
    begin
      id = params[:id].to_i
      jd_channel = params[:jd_channel].nil? ? 0 : params[:jd_channel].to_i
      key = Digest::MD5.hexdigest("jduutransdiyurl_#{params[:url]}_#{jd_channel}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      positionid = $default_jd_position_id
      if c = get_jd_channel
        positionid = c.source_id
      end
      r = JSON.parse(jd_union_open_promotion_bysubunionid_get_diyurl(params[:url], positionid))
      data = do_with_product_url(r)
      render json: data, callback: params[:callback]
      $dcl.set(key, data.to_json) if data[:status] == 200
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end
end
