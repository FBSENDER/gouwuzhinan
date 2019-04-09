require "digest/md5"
require "net/http"
require "json"
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

  def search
    action_params = {
      keyword: params[:keyword],
      sort_type: params[:sort_type] || 0,
      page: params[:page] || 1,
      page_size: params[:page_size] || 20,
      with_coupon: true
    }
    qq = system_params("pdd.ddk.goods.search").merge(action_params)
    my_sign = get_sign(qq)
    url = "http://gw-api.pinduoduo.com/api/router"
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    qq = qq.merge({sign: my_sign})
    request.body = qq.to_json
    response = http.request(request)
    data = JSON.parse(response.body)
    items = data["goods_search_response"]["goods_list"].map{|item| {
      itemId: item["goods_id"], 
      title: item["goods_name"],
      shortTitle: item["goods_name"],
      price: ((item["min_group_price"] / 100).to_s + "." + (item["min_group_price"] % 100).to_s).to_f,
      nowPrice: (((item["min_group_price"].to_i - item["coupon_discount"].to_i) / 100).to_s + "." + (item["min_group_price"] % 100).to_s).to_f,
      monthSales: item["sold_quantity"],
      coverImage: item["goods_thumbnail_url"],
      couponMoney: item["coupon_discount"].to_i / 100,
      couponStatTime: item["coupon_start_time"],
      couponEndTime: item["coupon_end_time"]
    }}
    render json: {status: {code: 1001}, result: items}, callback: params[:callback]
  end

  def goods_detail
    action_params = {
      goods_id_list: "[#{params[:id]}]"
    }
    qq = system_params("pdd.ddk.goods.detail").merge(action_params)
    my_sign = get_sign(qq)
    url = "http://gw-api.pinduoduo.com/api/router"
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    qq = qq.merge({sign: my_sign})
    request.body = qq.to_json
    response = http.request(request)
    begin
      data = JSON.parse(response.body)["goods_detail_response"]["goods_details"][0]
      render json: {status: {code: 1001}, result: {
        itemId: data["goods_id"],
        title: data["goods_name"],
        shortTitle: data["goods_name"],
        recommend: data["goods_desc"],
        price: data["min_group_price"].to_f / 100,
        nowPrice: (((data["min_group_price"].to_i - data["coupon_discount"].to_i) / 100).to_s + "." + (data["min_group_price"] % 100).to_s).to_f,
        monthSales: data["sold_quantity"],
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
    my_sign = get_sign(qq)
    url = "http://gw-api.pinduoduo.com/api/router"
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    qq = qq.merge({sign: my_sign})
    request.body = qq.to_json
    response = http.request(request)
    qrcode = JSON.parse(response.body)["weapp_qrcode_generate_response"]["url"]
    render json: {status: {code: 1001}, result: qrcode, callback: params[:callback]}
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
    my_sign = get_sign(qq)
    url = "http://gw-api.pinduoduo.com/api/router"
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    qq = qq.merge({sign: my_sign})
    request.body = qq.to_json
    response = http.request(request)
    result = JSON.parse(response.body)
    begin
      if urls = result["goods_promotion_url_generate_response"]["goods_promotion_url_list"][0]
        render json: {status: 1, result: urls}
      else
        render json: {status: 0}
      end
    rescue
      render json: {status: 0}
    end
  end
end
