require "digest/md5"
require 'net/http'
require "json"
require 'ddk'
require 'lanlan_api' 
require 'jdk_api'
require 'jd_media'
require 'uuhaodian'

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
      #if params[:id].nil? || params[:id].to_i <= 0
      if params[:id].nil?
        render json: {status: 0}
        return 
      end
      id = params[:id]
      key = Digest::MD5.hexdigest("jduuproduct_#{params[:id]}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      r = dataoke_get_jd_product_detail(id)
      data = do_with_search_result_product_dtk(r)
      render json: data, callback: params[:callback]
      $dcl.set(key, data.to_json) if data[:status] == 200
    rescue
      render json: {status: 0}, callback: params[:callback]
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
      is_pg = params[:is_pg]
      key = Digest::MD5.hexdigest("jduusearchbycat1_#{cid1}_#{page}_#{owner}_#{sort_name}_#{sort}_#{is_hot}_#{is_coupon}_#{is_pg}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      #r = jd_union_open_goods_query(page, 20, nil, cid1, nil, nil, nil, owner, sort_name, sort, is_coupon, is_pg, is_hot, nil, nil)
      r = dataoke_jd_search_normal(page, 20, nil, cid1, nil, nil, nil, owner, sort_name, sort, is_coupon, is_pg, is_hot, nil, nil)
      data = do_with_search_result_query_dtk(r)
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
      is_pg = params[:is_pg]
      key = Digest::MD5.hexdigest("jduusearchbycat3_#{cid3}_#{page}_#{owner}_#{sort_name}_#{sort}_#{is_hot}_#{is_coupon}_#{is_pg}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      #r = jd_union_open_goods_query(page, 20, nil, nil, nil, cid3, nil, owner, sort_name, sort, is_coupon, is_pg, is_hot, nil, nil)
      r = dataoke_jd_search_normal(page, 20, nil, nil, nil, cid3, nil, owner, sort_name, sort, is_coupon, is_pg, is_hot, nil, nil)
      data = do_with_search_result_query_dtk(r)
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
      is_pg = params[:is_pg]
      key = Digest::MD5.hexdigest("jduusearchbyshop_#{shop_id}_#{page}_#{cid3}_#{owner}_#{sort_name}_#{sort}_#{is_hot}_#{is_coupon}_#{is_pg}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      #r = jd_union_open_goods_query(page, 20, nil, nil, nil, cid3, nil, owner, sort_name, sort, is_coupon, is_pg, is_hot, shop_id, nil)
      r = dataoke_jd_search_normal(page, 20, nil, nil, nil, cid3, nil, owner, sort_name, sort, is_coupon, is_pg, is_hot, shop_id, nil)
      data = do_with_search_result_query_dtk(r)
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
      is_pg = params[:is_pg]
      key = Digest::MD5.hexdigest("jduusearchbybrand_#{brand_id}_#{page}_#{cid3}_#{owner}_#{sort_name}_#{sort}_#{is_hot}_#{is_coupon}_#{is_pg}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      #r = jd_union_open_goods_query(page, 20, nil, nil, nil, cid3, nil, owner, sort_name, sort, is_coupon, is_pg, is_hot, nil, brand_id)
      r = dataoke_jd_search_normal(page, 20, nil, nil, nil, cid3, nil, owner, sort_name, sort, is_coupon, is_pg, is_hot, nil, brand_id)
      data = do_with_search_result_query_dtk(r)
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
      #r = jd_union_open_goods_query(page, 20, nil, nil, nil, nil, ids, nil, nil, nil, nil, nil, nil, nil, nil)
      r = dataoke_jd_search_normal(page, 20, nil, nil, nil, nil, ids, nil, nil, nil, nil, nil, nil, nil, nil)
      data = do_with_search_result_query_dtk(r)
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
      is_pg = params[:is_pg]
      key = Digest::MD5.hexdigest("jduusearchbykeyword_#{keyword}_#{page}_#{cid3}_#{owner}_#{sort_name}_#{sort}_#{is_hot}_#{is_coupon}_#{is_pg}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      #(page, page_size, keyword, cid1, cid2, cid3, sku_ids, owner, sort_name, sort, is_coupon, is_pg, is_hot, shop_id, brand_code)
      #r = jd_union_open_goods_query(page, 20, keyword, nil, nil, cid3, nil, owner, sort_name, sort, is_coupon, is_pg, is_hot, nil, nil)
      r = dataoke_jd_search_normal(page, 20, keyword, nil, nil, cid3, nil, owner, sort_name, sort, is_coupon, is_pg, is_hot, nil, nil)
      data = do_with_search_result_query_dtk(r)
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
            spuid: d["spuid"],
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

  def do_with_search_result_query_dtk(r)
    begin
      result = JSON.parse(r)
      if result["code"] == 0 && result["data"] && result["data"]["list"] && result["data"]["list"].size > 0
        total = result["data"]["totalNum"] ? result["data"]["totalNum"].to_i : 0
        results = []
        result["data"]["list"].each do |d|
          item = {
            item_id: d["itemId"],
            title: d["skuName"],
            pict_url: d["whiteImage"],
            images: d["imageUrlList"],
            sales: d["inOrderCount30Days"],
            comments: d["comments"],
            good_share: d["goodCommentsShare"],
            product_url: d["materialUrl"],
            o_price: d["price"],
            lowest_price: d["lowestPrice"],
            lowest_coupon_price: d["lowestCouponPrice"],
            price_type: d["lowestPriceType"],
            shop_id: d["shopId"],
            shop_title: d["shopName"],
            spuid: d["spuid"],
            brand_code: d["brandCode"],
            brand_name: d["brandName"],
            cid1: d["cid1"],
            cid2: d["cid2"],
            cid3: d["cid3"],
            cname1: d["cid1Name"],
            cname2: d["cid2Name"],
            cname3: d["cid3Name"],
            coupon_amount: 0,
            coupon_url: "",
            coupon_quota: 0,
            coupon_type: 0,
            is_hot: 0,
            owner: d["owner"],
            end_time: 0
          }
          if d["couponList"].size > 0
            item[:coupon_amount] = d["couponList"][0]["discount"].to_i
            item[:coupon_url] = d["couponList"][0]["link"]
            item[:coupon_quota] = d["couponList"][0]["quota"].to_i
            item[:coupon_type] = d["couponList"][0]["bindType"]
            d["couponList"].each do |c|
              if c["isBest"] == 1
                item[:coupon_amount] = c["discount"].to_i
                item[:coupon_url] = c["link"]
                item[:coupon_quota] = c["quota"].to_i
                item[:coupon_type] = c["bindType"]
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

  def do_with_search_result_product_dtk(r)
    begin
      result = JSON.parse(r)
      if result["code"] == 0 && result["data"] && result["data"].size > 0
        d = result["data"][0]
        item = {
          item_id: d["skuId"],
          title: d["skuName"],
          pict_url: d["picMain"],
          detail_images: d["detailImages"],
          images: d["smallImages"],
          sales: d["inOrderCount30Days"],
          comments: d["comments"],
          good_share: d["goodCommentsShare"],
          product_url: d["materialUrl"],
          o_price: d["originPrice"],
          lowest_price: d["actualPrice"],
          lowest_coupon_price: d["actualPrice"],
          price_type: d["isSeckill"].to_i == 1 ? 2 : 0,
          shop_id: d["shopId"],
          shop_title: d["shopName"],
          is_hot: 0,
          owner: d["isOwner"],
          brand_code: "",
          brand_name: "",
          cid1: d["cid1"],
          cid2: d["cid2"],
          cid3: d["cid3"],
          cname1: d["cid1Name"],
          cname2: d["cid2Name"],
          cname3: d["cid3Name"],
          coupon_amount: d["couponAmount"],
          coupon_url: d["couponLink"],
          coupon_quota: d["couponRemainCount"],
          coupon_type: d["couponType"],
          end_time: 0
        }
        if d["couponUserEndTime"] && d["couponUserEndTime"].size > 0
          item[:end_time] = DateTime.strptime(d["couponUserEndTime"], "%Y-%m-%d %H:%M:%S").to_time.to_i
        end
        return {status: 200, result: item}
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

  def jd_home_items
    begin
      key = Digest::MD5.hexdigest("jduujdhomeitems")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      items = JdHomeItem.select(:id, :name, :sort, :filter_code).order(:sort).to_a
      data = {status: 1, results: items}
      render json: data, callback: params[:callback]
      $dcl.set(key, data.to_json) if data[:status] == 200
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def jd_home_json
    if params[:id].nil?
      render json: {status: 0}, callback: params[:callback]
      return
    end
    begin
      item_id = params[:id].to_i
      sort = params[:page].nil? ? 1 : params[:page].to_i
      key = Digest::MD5.hexdigest("jdhomejson_#{item_id}_#{sort}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      data = JdHomeJson.where(item_id: item_id, sort: sort).take
      if data.nil?
        render json: {status: 0}, callback: params[:callback]
        return
      end
      render json: data.content, callback: params[:callback]
      $dcl.set(key, data.content)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def jd_home_coupons
    begin
      page = params[:page].to_i
      item_id = params[:id].to_i
      key = Digest::MD5.hexdigest("jdhomecoupons_#{item_id}_#{page}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      coupon_ids = JdHomeItem.connection.execute("select sc.coupon_id
from jd_home_item_children c
join jd_home_item_children_shops s on s.parent_id = c.id
join jd_home_item_children_shop_coupons sc on sc.shop_id = s.id
where c.item_id = #{item_id}").to_a.map{|row| row[0]}

      coupons = JdCoupon.where(id: coupon_ids, status: 1).select(:mall_name, :product_id, :pic_url, :coupon_url, :quota, :discount, :id, :num, :remain).order("quota desc").offset(page * 30).limit(30)
      data = {status: 1, result: coupons}
      render json: data, callback: params[:callback]
      $dcl.set(key, data) if coupons.size > 0
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def jd_shop_json
    if params[:shop_id].nil?
      render json: {status: 0}, callback: params[:callback]
      return
    end
    begin
      shop_id = params[:shop_id].to_i
      key = Digest::MD5.hexdigest("jdshopjson_#{shop_id}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      data = JdShopJson.where(shop_id: shop_id).take
      if data.nil?
        render json: {status: 0}, callback: params[:callback]
        return
      end
      render json: data.content, callback: params[:callback]
      $dcl.set(key, data.content)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def new_jd_shop_seo_json_list
    key = Digest::MD5.hexdigest("newjdshopseojsonlist")
    if result = $dcl.get(key)
      render json: result
      return
    end
    sp = JdShopSeoJson.where(status: 1).select(:shop_id, :shop_name, :img_url, :cate3, :updated_at).order("id desc").limit(10)
    data = {status: 1, result: sp}
    render json: data, callback: params[:callback]
    $dcl.set(key, data)
  end

  def jd_shop_seo_json
    if params[:shop_id].nil?
      render json: {status: 0}, callback: params[:callback]
      return
    end
    begin
      shop_id = params[:shop_id].to_i
      key = Digest::MD5.hexdigest("jdshopseojson_#{shop_id}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      data = JdShopSeoJson.where(shop_id: shop_id).take
      if data.nil?
        render json: {status: 0}, callback: params[:callback]
        return
      end
      render json: data.content, callback: params[:callback]
      $dcl.set(key, data.content)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def jd_shop_home_list
    key = Digest::MD5.hexdigest("jdshophomelist")
    if result = $dcl.get(key)
      render json: result, callback: params[:callback]
      return
    end
    data = []
    JdShopSeoJson.connection.execute("select cate3
from jd_shop_seo_jsons
group by cate3
having count(0) >= 40 and cate3 <> ''
limit 5").to_a.each do |row|
      shops = JdShopSeoJson.where(cate3: row[0], status: 1).select(:id, :shop_id, :shop_name, :img_url, :updated_at).limit(5)
      data << {cate: row[0], shops: shops}
    end
    r = {status: 1, result: data}
    render json: r, callback: params[:callback]
    $dcl.set(key, r)
  end

  def jd_shop_all_cate
    key = Digest::MD5.hexdigest("jdshopallcate")
    if result = $dcl.get(key)
      render json: result, callback: params[:callback]
      return
    end
    data = JdShopSeoJson.connection.execute("select cate3, count(0)
from jd_shop_seo_jsons
group by cate3
having count(0) >= 40 and cate3 <> ''").to_a
    
    if data.nil? || data.size.zero?
      render json: {status: 0}, callback: params[:callback]
      return
    end
    r = {status: 1, result: data}
    render json: r, callback: params[:callback]
    $dcl.set(key, r)
  end

  def jd_shop_seo_list_by_cate
    cate = params[:cate]
    if cate.nil?
      render json: {status: 0}, callback: params[:callback]
      return
    end
    page = params[:page] || 0
    page = page.to_i
    data = JdShopSeoJson.where(cate3: cate, status: 1).select(:id, :shop_id, :shop_name, :img_url, :cate3, :updated_at).order("id desc").offset(20 * page).limit(20)
    total_page = (JdShopSeoJson.where(cate3: cate, status: 1).count * 1.0 / 20).ceil
    render json: {status: 1, result: data, total_page: total_page}, callback:params[:callback]
  end

  def jd_shop_seo_list_by_cate_ziying
    cate = params[:cate]
    if cate.nil?
      render json: {status: 0}, callback: params[:callback]
      return
    end
    data = JdShopSeoJson.where(cate3: cate, status: 1).where("shop_name like '%自营%'").select(:id, :shop_id, :shop_name, :img_url, :cate3, :updated_at).order("id desc").limit(20)
    render json: {status: 1, result: data, total_page: 1}, callback:params[:callback]
  end

  def home_page_json
    key = Digest::MD5.hexdigest("jduuhomepagejson")
    if result = $dcl.get(key)
      render json: result, callback: params[:callback]
      return
    end
    dtks = []
    DtkProduct.select(:dtitle, :id, :shopType, :shopName, :mainPic, :originalPrice, :actualPrice, :couponPrice, :monthSales).order(:id).offset((rand() * 1000).to_i * 20).limit(20).each do |dtk|
      d = {
        url: "/dtk/#{dtk.id}/",
        title: dtk.dtitle,
        pict_url: dtk.mainPic,
        tags: [],
        price: dtk.actualPrice,
        o_price: dtk.originalPrice,
        coupon: dtk.couponPrice,
        sales: dtk.monthSales > 10000 ? "#{(dtk.monthSales / 10000.0).round(1)}万" : dtk.monthSales
      }
      d[:tags] << (dtk.shopType == 1 ? '天猫' : '淘宝')
      d[:tags] << '旗舰店' if dtk.shopName.include?('旗舰店')
      dtks << d
    end
    coupons = []
    JdCoupon.where(cat: 1, status: 1).select(:mall_name, :product_id,:pic_url,:coupon_url,:quota,:discount).limit(6).each do |c|
      coupons << {
        item_id: c.product_id,
        discount: c.discount,
        quota: c.quota,
        pict_url: c.pic_url,
        shop: c.mall_name,
        url: "/jd/buy/#{c.product_id}/?coupon=#{URI.encode_www_form_component(c.coupon_url)}"
      }
    end
    jd_shops = []
    JdShopJson.select(:id, :shop_id, :shop_name).order(:id).offset((rand() * 6).to_i * 10).limit(10).each do |s|
      jd_shops << {
        name: s.shop_name,
        url: "/jdshop/#{s.shop_id}/"
      }
    end
    cores = []
    JdCoreKeyword.select(:id, :keyword).order(:id).offset((rand() * 163).to_i * 10).limit(10).each do |k|
      cores << {
        k: k.keyword,
        url: "/core_2_#{k.id}/"
      }
    end
    data = {status: 1, result:{dtk: dtks, coupons: coupons, jd_shops: jd_shops, cores: cores}}.to_json
    render json: data
    $dcl.set(key, data)
  end

  def new_zhinan_jd_static_product_keyword_list
    key = Digest::MD5.hexdigest("newzhinanjdstaticproductkeywordlist")
    if result = $dcl.get(key)
      render json: result
      return
    end
    sp = ZhinanJdStaticProduct.select(:id, :title).order("id desc").limit(10)
    k = sp.map{|s| s.title.split.last}.uniq
    data = {status: 1, result: k}
    render json: data, callback: params[:callback]
    $dcl.set(key, data)
  end

  def new_zhinan_jd_static_product_list
    key = Digest::MD5.hexdigest("newzhinanjdstaticproductlist")
    if result = $dcl.get(key)
      render json: result
      return
    end
    sp = ZhinanJdStaticProduct.select(:id, :source_id, :title, :price_info, :pic_url, :shop_id, :shop_title, :updated_at).order("id desc").limit(10)
    data = {status: 1, result: sp}
    render json: data, callback: params[:callback]
    $dcl.set(key, data)
  end

  def zhinan_jd_static_products
    key = Digest::MD5.hexdigest("zhinanjdstaticproduct_#{params[:id].to_i}")
    if result = $dcl.get(key)
      render json: result
      return
    end
    sp = ZhinanJdStaticProduct.where(id: params[:id].to_i).select(:info, :related, :liked, :updated_at).take
    if sp
      data = {status: 1, liked: sp.liked, info: JSON.parse(sp.info), related: JSON.parse(sp.related), updated_at: sp.updated_at}
      render json: data
      $dcl.set(key, data)
    else
      render json: {status: 0}
    end
  end

  def zhinan_jd_static_en_products
    key = Digest::MD5.hexdigest("zhinanjdstaticenproduct_#{params[:id].to_i}")
    if result = $dcl.get(key)
      render json: result
      return
    end
    sp = ZhinanJdStaticEnProduct.where(id: params[:id].to_i).select(:info, :related, :liked).take
    if sp
      data = {status: 1, liked: sp.liked, info: JSON.parse(sp.info), related: JSON.parse(sp.related) }
      render json: data
      $dcl.set(key, data)
    else
      render json: {status: 0}
    end
  end

  def zhinan_jd_static_product_like
    sp = ZhinanJdStaticProduct.where(id: params[:id].to_i).select(:id, :liked).take
    if sp
      sp.liked += 1
      sp.save
      render json: {status: 1}
    else
      render json: {status: 0}
    end
  end

  def zhinan_jd_en_keyword_1
    k = ZhinanJdEnKeyword.where(keyword: params[:keyword]).take
    if k.nil? || k.product_num < 10
      render json: {status: 0}
      return
    end
    key = Digest::MD5.hexdigest("zhinanjdenkeyword1_#{k.id}")
    if result = $dcl.get(key)
      render json: result
      return
    end
    ks = ZhinanJdEnKeyword.where("id > ? and product_num >= 10", k.id).order(:id).limit(10).pluck(:keyword)
    products = []
    ids = ZhinanJdEnKpRelation.where(keyword_id: k.id).order(:id).limit(10).pluck(:product_id)
    ZhinanJdStaticEnProduct.connection.execute("select s.id, s.title, s.price_info, s.pic_url, p.disc 
from zhinan_jd_static_en_products s
join zhinan_jd_fxhh_en_products p on s.source_id = p.source_id
where s.id in (#{ids.join(',')})").to_a.each do |row|
      products << {
        id: row[0],
        title: row[1],
        price_info: row[2],
        pic_url: row[3],
        disc: row[4]
      }
    end
    data = {status: 1, keyword: k.keyword, num: k.product_num, ks: ks, data: products}
    render json: data
    $dcl.set(key, data)
  end

  def zhinan_jd_en_keyword_2
    k = ZhinanJdEnKeyword.where(keyword: params[:keyword]).take
    if k.nil? || k.product_num < 20
      render json: {status: 0}
      return
    end
    key = Digest::MD5.hexdigest("zhinanjdenkeyword2_#{k.id}")
    if result = $dcl.get(key)
      render json: result
      return
    end
    products = []
    ks = ZhinanJdEnKeyword.where("id > ? and product_num >= 20", k.id).order(:id).limit(10).pluck(:keyword)
    ids = ZhinanJdEnKpRelation.where(keyword_id: k.id).order("id desc").limit(10).pluck(:product_id)
    ZhinanJdStaticEnProduct.connection.execute("select s.id, s.title, s.price_info, s.pic_url, p.disc 
from zhinan_jd_static_en_products s
join zhinan_jd_fxhh_en_products p on s.source_id = p.source_id
where s.id in (#{ids.join(',')})").to_a.each do |row|
      products << {
        id: row[0],
        title: row[1],
        price_info: row[2],
        pic_url: row[3],
        disc: row[4]
      }
    end
    data = {status: 1, keyword: k.keyword, num: k.product_num, ks: ks, data: products}
    render json: data
    $dcl.set(key, data)
  end

  def jd_seo_data_old
    key = Digest::MD5.hexdigest("jdseodata")
    if result = $dcl.get(key)
      render json: result
      return
    end
    ids = (1..1655).to_a.sample(10)
    core = JdCoreKeyword.where(id: ids).select(:id, :keyword).to_a
    ids = (1..67).to_a.sample(10)
    shop = JdShopJson.where(id: ids).select(:shop_id, :shop_name).to_a
    ids = (1..1000).to_a.sample(12)
    pro = ZhinanJdStaticProduct.where(id: ids).select(:id, :title, :pic_url).to_a
    data = {status: 1, cores: core, shops: shop, products: pro}
    render json: data
    $dcl.set(key, data)
  end

  def jd_seo_data
    ids = (1..1655).to_a.sample(10)
    core = JdCoreKeyword.where(id: ids).select(:id, :keyword).to_a
    shops = JdShopSeoJson.where(status: 1).select(:shop_id, :shop_name, :img_url, :cate3, :updated_at).order("id desc").limit(10)
    products = ZhinanJdStaticProduct.select(:id, :source_id, :title, :price_info, :pic_url, :shop_id, :shop_title, :updated_at).order("id desc").limit(10)
    keywords = products.map{|s| s.title.split.last}.uniq
    data = {status: 1, cores: core, shops: shops, products: products, keyword: keywords}
    render json: data
  end

  def jd_open_search
    #if is_robot?
    #  render json: {status: 0}
    #  return
    #end
    page = params[:page].to_i
    page = page <= 0 ? 0 : page
    keyword = params[:keyword]
    if keyword.nil? || keyword.empty?
      render json: {status: 0}
      return
    end
    # return nil
    render json: {status: 0}
    #keyword = keyword.strip
    #q = "query=default:\'#{keyword}\'&&config=start:#{page * 20},hit:20,format:json"
    #f = URI.encode_www_form_component("id;source_id;title;price_info;pic_url;shop_id;shop_title")
    #u = "/v3/openapi/apps/150052662/search?fetch_fields=#{f}&query=#{URI.encode_www_form_component(q)}"
    #url = "http://opensearch-cn-shanghai.aliyuncs.com#{u}"
    #time = Time.now.utc.to_s.gsub(" UTC", "Z").gsub(" ", "T")
    #nonce = (Time.now.to_f.round(3) * 1000).to_i.to_s + (1000..9999).to_a.sample.to_s
    #sign = opensearch_signature(u, nonce, time)
    #uri = URI(url)
    #req = Net::HTTP::Get.new(uri)
    #req["Content-MD5"] = ""
    #req["Content-Type"] = "application/json"
    #req["Authorization"] = "OPENSEARCH #{$ali_open_search_key}:#{sign}"
    #req["X-Opensearch-Nonce"] = nonce
    #req["Date"] = time
    #res = Net::HTTP.start(uri.hostname, uri.port) {|http|
    #  http.request(req)
    #}
    #render json: res.body
  end

  def opensearch_signature(query_str, nonce, time)
    str = ["GET", "", "application/json", time, "x-opensearch-nonce:#{nonce}", query_str]

    Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest.new("sha1"),
        $ali_open_search_secret,
        str.join("\n")
      )
    ).strip
  end
end
