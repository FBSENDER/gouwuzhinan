require "digest/md5"
require "net/http"
require "json"
require 'ddk'

class DdkController < ApplicationController
  skip_before_action :verify_authenticity_token
  def system_params(method)
    {
      type: method,
      client_id: "4ebb305473ac45358a55841fe27de58f",
      timestamp: Time.now.to_i,
      data_type: "JSON",
    }
  end

  def get_sign(hash)
    s = "8fc404fdcfdd91996e3e6b704ee0934cb20bcd9d"
    Digest::MD5.hexdigest(hash.sort.flatten.push(s).unshift(s).join("")).upcase
  end

  def do_request(qq)
    my_sign = get_sign(qq)
    url = "http://gw-api.pinduoduo.com/api/router"
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    qq = qq.merge({sign: my_sign})
    request.body = qq.to_json
    http.request(request)
  end
  
  def convert_list_item(item)
    {
      itemId: item["goods_id"], 
      title: item["goods_name"],
      shortTitle: item["goods_name"],
      price: ((item["min_group_price"] / 100).to_s + "." + (item["min_group_price"] % 100).to_s).to_f,
      nowPrice: (((item["min_group_price"].to_i - item["coupon_discount"].to_i) / 100).to_s + "." + (item["min_group_price"] % 100).to_s).to_f,
      monthSales: item["sales_tip"],
      coverImage: item["goods_thumbnail_url"],
      couponMoney: item["coupon_discount"].to_i / 100,
      couponStatTime: item["coupon_start_time"],
      couponEndTime: item["coupon_end_time"]
    }
  end

  def search
    action_params = {
      keyword: params[:keyword],
      sort_type: params[:sort_type] || 0,
      page: params[:page] || 1,
      page_size: params[:page_size] || 20,
      with_coupon: true
    }
    qq = system_params("pdd.ddk.goods.search").merge(action_params)
    response = do_request(qq)
    data = JSON.parse(response.body)
    items = data["goods_search_response"]["goods_list"].map{|item| convert_list_item(item)}
    render json: {status: {code: 1001}, result: items}, callback: params[:callback]
  end

  def goods_detail
    action_params = {
      goods_id_list: "[#{params[:id]}]"
    }
    qq = system_params("pdd.ddk.goods.detail").merge(action_params)
    response = do_request(qq)
    data = JSON.parse(response.body)
    begin
      data = JSON.parse(response.body)["goods_detail_response"]["goods_details"][0]
      render json: {status: {code: 1001}, result: {
        itemId: data["goods_id"],
        title: data["goods_name"],
        shortTitle: data["goods_name"],
        recommend: data["goods_desc"],
        price: data["min_group_price"].to_f / 100,
        nowPrice: (((data["min_group_price"].to_i - data["coupon_discount"].to_i) / 100).to_s + "." + (data["min_group_price"] % 100).to_s).to_f,
        monthSales: data["sales_tip"],
        sellerName: data["mall_name"],
        category: data["opt_name"],
        coverImage: data["goods_thumbnail_url"],
        shopType: "pinduoduo",
        auctionImages: data["goods_gallery_urls"],
        detailImages: [],
        couponMoney: data["coupon_discount"].to_i / 100,
        couponStartTime: data["coupon_start_time"],
        couponEndTime: data["coupon_end_time"]
      }}, callback: params[:callback]
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def get_wx_qrcode
    action_params = {
      p_id: "1781779_28462207",
      goods_id_list:"[\"#{params[:id]}\"]"
    }
    qq = system_params("pdd.ddk.weapp.qrcode.url.gen").merge(action_params)
    response = do_request(qq)
    qrcode = JSON.parse(response.body)["weapp_qrcode_generate_response"]["url"]
    render json: {status: {code: 1001}, result: qrcode}, callback: params[:callback]
  end

  def get_promotion_url
    action_params = {
      p_id: "1781779_28462207",
      goods_id_list:"[\"#{params[:id]}\"]",
      generate_short_url: true,
      multi_group: true,
      generate_weapp_webview: true,
      generate_we_app: true
    }
    qq = system_params("pdd.ddk.goods.promotion.url.generate").merge(action_params)
    response = do_request(qq)
    result = JSON.parse(response.body)
    begin
      if urls = result["goods_promotion_url_generate_response"]["goods_promotion_url_list"][0]
        render json: {status: 1, result: urls}, callback: params[:callback]
      else
        render json: {status: 0}, callback: params[:callback]
      end
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def get_mall_url
    action_params = {
      pid: "1781779_28462207",
      mall_id: params[:id],
      generate_short_url: true,
      multi_group: true,
      generate_weapp_webview: true,
      generate_we_app: true
    }
    qq = system_params("pdd.ddk.mall.url.gen").merge(action_params)
    response = do_request(qq)
    result = JSON.parse(response.body)
    begin
      if urls = result["mall_coupon_generate_url_response"]["list"][0]
        render json: {status: 1, result: urls}, callback: params[:callback]
      else
        render json: {status: 0}, callback: params[:callback]
      end
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def hot_list
    sort = params[:type] == 2 ? 2 : 1
    page =  params[:page] || 1
    page_size = params[:page_size] || 20
    offset = (page.to_i - 1) * page_size.to_i
    action_params = {
      sort_type: sort,
      offset: offset,
      limit: page_size
    }
    qq = system_params("pdd.ddk.top.goods.list.query").merge(action_params)
    begin
      response = do_request(qq)
      data = JSON.parse(response.body)
      items = data["top_goods_list_get_response"]["list"].map{|item| convert_list_item(item)}
      render json: {status: {code: 1001}, result: items}, callback: params[:callback]
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def rec_list
    # 需要授权
    # 0, "1.9包邮", 1, "今日爆款", 2, "品牌清仓"
    channel_type = params[:type] || 1
    page =  params[:page] || 1
    page_size = params[:page_size] || 20
    offset = (page.to_i - 1) * page_size.to_i
    action_params = {
      channel_type: channel_type,
      offset: offset,
      limit: page_size
    }
    qq = system_params("pdd.ddk.goods.recommend.get").merge(action_params)
    begin
      response = do_request(qq)
      data = JSON.parse(response.body)
      items = data["goods_basic_detail_response"]["list"].map{|item| convert_list_item(item)}
      render json: {status: {code: 1001}, result: items}, callback: params[:callback]
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def theme_list
    page =  params[:page] || 1
    page_size = params[:page_size] || 20
    action_params = {
      page: page,
      page_size: page_size
    }
    qq = system_params("pdd.ddk.theme.list.get").merge(action_params)
    begin
      response = do_request(qq)
      data = JSON.parse(response.body)
      render json: data, callback: params[:callback]
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def theme_detail
    action_params = {
      theme_id: params[:id]
    }
    qq = system_params("pdd.ddk.theme.goods.search").merge(action_params)
    begin
      response = do_request(qq)
      data = JSON.parse(response.body)
      items = data["theme_list_get_response"]["goods_list"].map{|item| convert_list_item(item)}
      render json: {status: {code: 1001}, result: items}, callback: params[:callback]
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def mall_info
    shop = DdkShop.where(mall_id: params[:id].to_i).take
    if shop.nil?
      render json: {status: 0}
      return
    end
    s = {mall_id: shop.mall_id, mall_name: shop.mall_name, mall_type: shop.mall_type, cats: shop.cat_names, img_url: shop.img_url, quantity: shop.quantity}
    coupon = DdkShopCoupon.where(mall_id: params[:id].to_i).take
    if coupon
      c = {discount: coupon.discount, min_order_amount: coupon.min_order_amount, max_discount_amount: coupon.max_discount_amount, total: coupon.total, left: coupon.left, start_time: coupon.start_time, end_time: coupon.end_time}
      render json: {status: 1, result: {mall: s, coupon: c}}, callback: params[:callback]
    else
      render json: {status: 1, result: {mall: s, coupon: nil}}, callback: params[:callback]
    end
  end

  def mall_products
    action_params = {
      mall_id: params[:id],
      page_number: params[:page] || 1,
      page_size: params[:page_size] || 20
    }
    qq = system_params("pdd.ddk.mall.goods.list.get").merge(action_params)
    begin
      response = do_request(qq)
      data = JSON.parse(response.body)
      items = data["goods_info_list_response"]["goods_list"].map{|item| convert_list_item(item)}
      render json: {status: {code: 1001}, result: items}, callback: params[:callback]
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def mall_list
    cid = params[:cid] || 5
    page = params[:page] || 1
    page_size = params[:page_size] || 20
    only_qjd = params[:qjd] || 0
    sort = params[:sort] || 0
    os = (page.to_i - 1) * page_size.to_i
    order = sort.to_i == 0 ? "quantity desc" : "discount"
    if only_qjd && only_qjd.to_i > 0
      shops = DdkShop.joins("left join ddk_shop_coupons c on c.mall_id = ddk_shops.mall_id").where(cat_ids: cid.to_s, mall_type: 3).select("img_url,ddk_shops.mall_id,c.discount / 10 as mall_rate, mall_name, mall_type, quantity, cat_names,ddk_shops.id").order(order).offset(os).limit(page_size.to_i)
    else
      shops = DdkShop.joins("left join ddk_shop_coupons c on c.mall_id = ddk_shops.mall_id").where(cat_ids: cid.to_s).select("img_url,ddk_shops.mall_id,c.discount / 10 as mall_rate, mall_name, mall_type, quantity, cat_names,ddk_shops.id").order(order).offset(os).limit(page_size.to_i)
    end
    render json: {status: 1, result: shops}, callback: params[:callback]
  end

end
