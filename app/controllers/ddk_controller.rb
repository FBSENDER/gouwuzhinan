require "digest/md5"
require "net/http"
require "json"
require 'ddk'
require 'lanlan_api'

class DdkController < ApplicationController
  skip_before_action :verify_authenticity_token
  def system_params(method)
    {
      type: method,
      client_id: $ddk_id,
      timestamp: Time.now.to_i,
      data_type: "JSON",
    }
  end

  def get_sign(hash)
    s = $ddk_secret
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
      #itemId: item["goods_id"], 
      itemId: item["goods_sign"], 
      title: item["goods_name"],
      shortTitle: item["goods_name"],
      price: ((item["min_group_price"] / 100).to_s + "." + (item["min_group_price"] % 100).to_s).to_f,
      nowPrice: (((item["min_group_price"].to_i - item["coupon_discount"].to_i) / 100).to_s + "." + (item["min_group_price"] % 100).to_s).to_f,
      monthSales: item["sales_tip"],
      coverImage: item["goods_thumbnail_url"],
      couponMoney: item["coupon_discount"].to_i / 100,
      couponStatTime: item["coupon_start_time"],
      couponEndTime: item["coupon_end_time"],
      shopName: item["mall_name"],
      activityTags: item["activity_tags"],
      recommend: item["goods_desc"]
    }
  end

  def search
    begin
      action_params = {
        keyword: params[:keyword],
        sort_type: params[:sort_type] || 0,
        page: params[:page] || 1,
        page_size: params[:page_size] || 20,
        pid: $ddk_default_pid,
        with_coupon: true
      }
      key = Digest::MD5.hexdigest("ddksearch_#{action_params[:keyword]}_#{action_params[:sort_type]}_#{action_params[:page]}_#{action_params[:page_size]}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      qq = system_params("pdd.ddk.goods.search").merge(action_params)
      response = do_request(qq)
      data = JSON.parse(response.body)
      items = data["goods_search_response"]["goods_list"].map{|item| convert_list_item(item)}
      d_data = {status: {code: 1001}, result: items}
      render json: d_data, callback: params[:callback]
      $dcl.set(key, d_data.to_json)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def search_2
    begin
      atags = params[:activity].nil? ? '[]' : '[' + params[:activity] + ']'
      action_params = {
        keyword: params[:keyword],
        sort_type: params[:sort_type] || 0,
        page: params[:page] || 1,
        page_size: params[:page_size] || 20,
        activity_tags: atags,
        pid: $ddk_default_pid,
        with_coupon: params[:has_coupon].nil? ? false : params[:has_coupon]
      }
      key = Digest::MD5.hexdigest("ddksearch_#{action_params[:keyword]}_#{action_params[:sort_type]}_#{atags}_#{action_params[:with_coupon]}_#{action_params[:page]}_#{action_params[:page_size]}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      qq = system_params("pdd.ddk.goods.search").merge(action_params)
      response = do_request(qq)
      data = JSON.parse(response.body)
      items = data["goods_search_response"]["goods_list"].map{|item| convert_list_item(item)}
      d_data = {status: {code: 1001}, result: items}
      render json: d_data, callback: params[:callback]
      $dcl.set(key, d_data.to_json)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def get_opt_products
    begin
      atags = params[:activity].nil? ? '[]' : '[' + params[:activity] + ']'
      coupon = params[:coupon].nil? ? 0 : params[:coupon].to_i
      action_params = {
        opt_id: params[:opt],
        sort_type: params[:sort_type] || 0,
        page: params[:page] || 1,
        page_size: params[:page_size] || 20,
        activity_tags: atags,
        pid: $ddk_default_pid,
        with_coupon: coupon > 0
      }
      key = Digest::MD5.hexdigest("ddkoptproducts_#{action_params[:opt_id]}_#{action_params[:sort_type]}_#{action_params[:activity_tags]}_#{coupon}_#{action_params[:page]}_#{action_params[:page_size]}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      qq = system_params("pdd.ddk.goods.search").merge(action_params)
      response = do_request(qq)
      data = JSON.parse(response.body)
      items = data["goods_search_response"]["goods_list"].map{|item| convert_list_item(item)}
      d_data = {status: {code: 1001}, result: items}
      render json: d_data, callback: params[:callback]
      $dcl.set(key, d_data.to_json)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def goods_detail
    begin
      id = params[:id]
      key = Digest::MD5.hexdigest("ddkgoodsdetail_#{id}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      action_params = {
        goods_sign: id
      }
      qq = system_params("pdd.ddk.goods.detail").merge(action_params)
      rsp = do_request(qq)
      data = JSON.parse(rsp.body)["goods_detail_response"]["goods_details"][0]
      d_data = {status: {code: 1001}, result: {
        itemId: data["goods_sign"],
        title: data["goods_name"],
        shortTitle: data["goods_name"],
        recommend: data["goods_desc"],
        price: data["min_group_price"].to_f / 100,
        nowPrice: (((data["min_group_price"].to_i - data["coupon_discount"].to_i) / 100).to_s + "." + (data["min_group_price"] % 100).to_s).to_f,
        monthSales: data["sales_tip"],
        sellerName: data["mall_name"],
        sellerId: data["mall_id"],
        category: data["opt_name"],
        coverImage: data["goods_thumbnail_url"],
        shopType: "pinduoduo",
        auctionImages: data["goods_gallery_urls"],
        detailImages: [],
        couponMoney: data["coupon_discount"].to_i / 100,
        couponStartTime: data["coupon_start_time"],
        couponEndTime: data["coupon_end_time"],
        optId: data["opt_id"],
        optName: data["opt_name"],
        optIds: data["opt_ids"]
      }}
      render json: d_data, callback: params[:callback]
      $dcl.set(key, d_data.to_json)
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

  def get_wx_qrcode_new
    begin
      goods_id = params[:id].to_i
      channel = get_channel
      pid = channel.nil? ? $ddk_default_pid : channel.pid
      key = Digest::MD5.hexdigest("ddkwxqrcode_#{goods_id}_#{pid}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      action_params = {
        p_id: pid,
        goods_id_list:"[\"#{goods_id}\"]"
      }
      qq = system_params("pdd.ddk.weapp.qrcode.url.gen").merge(action_params)
      response = do_request(qq)
      qrcode = JSON.parse(response.body)["weapp_qrcode_generate_response"]["url"]
      d_data = {status: {code: 1001}, result: qrcode}
      render json: d_data, callback: params[:callback]
      $dcl.set(key, d_data.to_json)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def get_promotion_url
    ddkid = params[:pid] || "1781779_28462207"
    action_params = {
      p_id: ddkid,
      goods_id_list:"[\"#{params[:id]}\"]",
      generate_short_url: true,
      multi_group: true,
      generate_weapp_webview: true,
      generate_we_app: true,
      generate_qq_app: true
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

  def get_promotion_url_new
    begin
      goods_id = params[:id]
      channel = get_channel
      pid = channel.nil? ? $ddk_default_pid : channel.pid
      key = Digest::MD5.hexdigest("ddkpromotionurl_#{goods_id}_#{pid}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      action_params = {
        p_id: pid,
        goods_sign_list:"[\"#{goods_id}\"]",
        generate_authority_url: true,
        generate_short_url: true,
        multi_group: true,
        generate_weapp_webview: true,
        generate_we_app: true,
        generate_qq_app: true
      }
      qq = system_params("pdd.ddk.goods.promotion.url.generate").merge(action_params)
      response = do_request(qq)
      result = JSON.parse(response.body)
      if urls = result["goods_promotion_url_generate_response"]["goods_promotion_url_list"][0]
        d_data = {status: 1, result: urls}
        render json: d_data, callback: params[:callback]
        $dcl.set(key, d_data.to_json)
      else
        render json: {status: 0}, callback: params[:callback]
      end
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def get_mall_url
    begin
      mall_id = params[:id].to_i
      channel = get_channel
      pid = channel.nil? ? $ddk_default_pid : channel.pid
      key = Digest::MD5.hexdigest("ddkmallurl_#{mall_id}_#{pid}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      action_params = {
        pid: pid,
        mall_id: mall_id,
        generate_short_url: true,
        multi_group: true,
        generate_weapp_webview: true,
        generate_we_app: true,
        generate_qq_app: true
      }
      qq = system_params("pdd.ddk.mall.url.gen").merge(action_params)
      response = do_request(qq)
      result = JSON.parse(response.body)
      if urls = result["mall_coupon_generate_url_response"]["list"][0]
        d_data = {status: 1, result: urls}
        render json: d_data, callback: params[:callback]
        $dcl.set(key, d_data.to_json)
      else
        render json: {status: 0}, callback: params[:callback]
      end
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def hot_list
    begin
      sort = params[:type] == 2 ? 7 : 5
      page =  params[:page] || 1
      page_size = params[:page_size] || 20
      page = 6 if page.to_i > 6
      key = Digest::MD5.hexdigest("ddkhotlist_#{sort}_#{page}_#{page_size}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      offset = (page.to_i - 1) * page_size.to_i
      action_params = {
        channel_type: sort,
        offset: offset,
        limit: page_size
      }
      qq = system_params("pdd.ddk.goods.recommend.get").merge(action_params)
      response = do_request(qq)
      data = JSON.parse(response.body)
      items = data["goods_basic_detail_response"]["list"].map{|item| convert_list_item(item)}
      d_data = {status: {code: 1001}, result: items}
      render json: d_data, callback: params[:callback]
      $dcl.set(key, d_data.to_json)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def rec_list
    # 需要授权
    # 0, "1.9包邮", 1, "今日爆款", 2, "品牌清仓"
    begin
      channel_type = params[:type] || 1
      page =  params[:page] || 1
      page_size = params[:page_size] || 20
      key = Digest::MD5.hexdigest("ddkreclist_#{channel_type}_#{page}_#{page_size}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      offset = (page.to_i - 1) * page_size.to_i
      action_params = {
        channel_type: channel_type,
        offset: offset,
        limit: page_size
      }
      qq = system_params("pdd.ddk.goods.recommend.get").merge(action_params)
      response = do_request(qq)
      data = JSON.parse(response.body)
      items = data["goods_basic_detail_response"]["list"].map{|item| convert_list_item(item)}
      d_data = {status: {code: 1001}, result: items}
      render json: d_data, callback: params[:callback]
      $dcl.set(key, d_data.to_json)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def theme_list
    begin
      page =  params[:page] || 1
      page_size = params[:page_size] || 20
      key = Digest::MD5.hexdigest("ddkthemelist_#{page}_#{page_size}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      action_params = {
        page: page,
        page_size: page_size
      }
      qq = system_params("pdd.ddk.theme.list.get").merge(action_params)
      response = do_request(qq)
      data = JSON.parse(response.body)
      d_data = {status: 1, result: data["theme_list_get_response"]["theme_list"]}
      render json: d_data, callback: params[:callback]
      $dcl.set(key, d_data.to_json)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def theme_detail
    begin
      theme_id = params[:id]
      key = Digest::MD5.hexdigest("ddkthemedetail_#{theme_id}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      action_params = {
        theme_id: theme_id
      }
      qq = system_params("pdd.ddk.theme.goods.search").merge(action_params)
      response = do_request(qq)
      data = JSON.parse(response.body)
      items = data["theme_list_get_response"]["goods_list"].map{|item| convert_list_item(item)}
      d_data = {status: {code: 1001}, result: items}
      render json: d_data, callback: params[:callback]
      $dcl.set(key, d_data.to_json)
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
    begin
      mall_id = params[:id].to_i
      page = params[:page] || 1
      page_size = params[:page_size] || 20
      key = Digest::MD5.hexdigest("ddkmallproducts_#{mall_id}_#{page}_#{page_size}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      action_params = {
        mall_id: mall_id,
        page_number: page,
        page_size: page_size 
      }
      qq = system_params("pdd.ddk.mall.goods.list.get").merge(action_params)
      response = do_request(qq)
      data = JSON.parse(response.body)
      items = data["goods_info_list_response"]["goods_list"].map{|item| convert_list_item(item)}
      d_data = {status: {code: 1001}, result: items}
      render json: d_data, callback: params[:callback]
      $dcl.set(key, d_data.to_json)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def group_products
    begin
      group_id = params[:id].to_i
      key = Digest::MD5.hexdigest("ddkgroupproducts_#{group_id}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      ids = DdkGroupProduct.where(group_id: group_id).order("id desc").limit(40).pluck(:product_id).uniq
      if ids.size.zero?
        render json: {status: 0}, callback: params[:callback]
        return
      end
      action_params = {
        goods_id_list: '[' + ids.join(',') + ']',
        pid: $ddk_default_pid
      }
      qq = system_params("pdd.ddk.goods.search").merge(action_params)
      response = do_request(qq)
      data = JSON.parse(response.body)
      items = data["goods_search_response"]["goods_list"].map{|item| convert_list_item(item)}
      d_data = {status: {code: 1001}, result: items}
      render json: d_data, callback: params[:callback]
      $dcl.set(key, d_data.to_json)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def get_opt_list
    data = {status: 1, result: [{"opt_name":"食品","opt_id":1},{"opt_name":"女装","opt_id":14},{"opt_name":"水果","opt_id":13},{"opt_name":"男装","opt_id":743},{"opt_name":"百货","opt_id":15},{"opt_name":"美妆","opt_id":16},{"opt_name":"生活个护","opt_id":2946},{"opt_name":"母婴","opt_id":4},{"opt_name":"家纺","opt_id":818},{"parent_opt_id":0,"level":1,"opt_name":"鞋包","opt_id":1281},{"opt_name":"内衣","opt_id":1282},{"opt_name":"运动","opt_id":1451},{"opt_name":"手机","opt_id":1543},{"opt_name":"家装","opt_id":1917},{"opt_name":"汽摩","opt_id":2048},{"opt_name":"大家电","opt_id":2964},{"opt_name":"电器","opt_id":18},{"opt_name":"电脑","opt_id":2478}]}
    render json: data, callback: params[:callback]
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

  def get_channel
    if params[:channel].nil?
      return nil
    end
    if $ddk_channels.nil? || (Time.now.to_i - $ddk_channels_update) > 3600
      $ddk_channels = DdkChannel.all.to_a
      $ddk_channels_update = Time.now.to_i
    end
    $ddk_channels.each do |c|
      return c if c.id == params[:channel].to_i
    end
    nil
  end

  def jd_search
    begin
      if params[:is_hot] && params[:is_hot].to_i == 1 
        is_hot = 1
      else
        is_hot = 0
      end
      if params[:owner] == 'p' || params[:owner] == 'g'
        owner = params[:owner]
      else
        owner = ''
      end
      # sort_type 1 销量 2 单价 降序 3 单价升序
      if params[:sort_type] && params[:sort_type].to_i == 1
        sort_type = 1
      elsif params[:sort_type] && params[:sort_type].to_i == 2
        sort_type = 2
      elsif params[:sort_type] && params[:sort_type].to_i == 3 
        sort_type = 3
      else
        sort_type = 0
      end
      action_params = {
        apikey: $mayi_key,
        keyword: params[:keyword],
        pageindex: params[:page] || 1,
        pagesize: params[:page_size] || 20,
        iscoupon: params[:has_coupon] && params[:has_coupon].to_i == 1 ? 1 : 0
      }
      if is_hot == 1
        action_params[:ishot] = 1
      end
      if owner != ''
        action_params[:owner] = owner
      end
      if sort_type == 1
        action_params[:sortname] = 4
      elsif sort_type == 2
        action_params[:sortname] = 1
      elsif sort_type == 3
        action_params[:sortname] = 1
        action_params[:sort] = 'asc'
      end
      key = Digest::MD5.hexdigest("jdsearch_#{action_params[:keyword]}_#{sort_type}_#{owner}_#{is_hot}_#{action_params[:iscoupon]}_#{action_params[:pageindex]}_#{action_params[:pagesize]}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      uri = URI("http://api-gw.haojingke.com/index.php/v1/api/jd/goodslist")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = action_params.to_json
      response = http.request(request)
      data = response.body
      render json: data, callback: params[:callback]
      $dcl.set(key, data)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def jd_mall_products
    begin
      cid3 = params[:cid3]
      has_coupon = params[:has_coupon]
      action_params = {
        apikey: $mayi_key,
        shopid: params[:id].to_i,
        iscoupon: 0
      }
      if cid3
        action_params[:cid3] = cid3
      end
      if has_coupon && has_coupon.to_i == 1
        action_params[:iscoupon] = 1
      end
      key = Digest::MD5.hexdigest("jdmallproducts_#{action_params[:shopid]}_#{action_params[:iscoupon]}_#{cid3}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      uri = URI("http://api-gw.haojingke.com/index.php/v1/api/jd/goodslist")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = action_params.to_json
      response = http.request(request)
      data = response.body
      render json: data, callback: params[:callback]
      $dcl.set(key, data)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def jd_product
    begin
      id = params[:id].to_i
      key = Digest::MD5.hexdigest("jdproductdetail_#{id}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      action_params = {
        apikey: $mayi_key,
        goods_id: id
      }
      uri = URI("http://api-gw.haojingke.com/index.php/v1/api/jd/goodsdetail")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = action_params.to_json
      response = http.request(request)
      data = response.body
      render json: data, callback: params[:callback]
      $dcl.set(key, data)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def jd_product_url
    begin
      id = params[:id].to_i
      jd_channel = params[:jd_channel].nil? ? 0 : params[:jd_channel].to_i
      key = Digest::MD5.hexdigest("jdproductdetailurl_#{id}_#{jd_channel}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      positionid = $default_jd_position_id
      if c = get_jd_channel
        positionid = c.source_id
      end
      action_params = {
        apikey: $mayi_key,
        goods_id: id,
        positionid: positionid,
        type: 1
      }
      if params[:coupon]
        action_params[:couponurl] = params[:coupon]
      end
      uri = URI("http://api-gw.haojingke.com/index.php/v1/api/jd/getunionurl")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = action_params.to_json
      response = http.request(request)
      data = response.body
      render json: data, callback: params[:callback]
      $dcl.set(key, data)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def jd_cat_products
    begin
      if params[:is_hot] && params[:is_hot].to_i == 1 
        is_hot = 1
      else
        is_hot = 0
      end
      if params[:owner] == 'p' || params[:owner] == 'g'
        owner = params[:owner]
      else
        owner = ''
      end
      if params[:id]
        cid1 = params[:id].to_i
      else
        cid1 = 0
      end
      action_params = {
        apikey: $mayi_key,
        pageindex: params[:page] || 1,
        pagesize: params[:page_size] || 20,
        sortname: 4,
        iscoupon: params[:has_coupon] && params[:has_coupon].to_i == 1 ? 1 : 0
      }
      if cid1 > 0
        action_params[:cid1] = cid1
      end
      if is_hot == 1
        action_params[:ishot] = 1
      end
      if owner != ''
        action_params[:owner] = owner
      end
      key = Digest::MD5.hexdigest("jdsearch_#{cid1}_#{owner}_#{is_hot}_#{action_params[:iscoupon]}_#{action_params[:pageindex]}_#{action_params[:pagesize]}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      uri = URI("http://api-gw.haojingke.com/index.php/v1/api/jd/goodslist")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = action_params.to_json
      response = http.request(request)
      data = response.body
      render json: data, callback: params[:callback]
      $dcl.set(key, data)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def jd_coupons
    begin
      page = params[:page].to_i
      cid = params[:cid].to_i
      key = Digest::MD5.hexdigest("jdcoupons_#{cid}_#{page}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      coupons = JdCoupon.where(cat: cid, status: 1).select(:mall_name, :product_id, :pic_url, :coupon_url, :quota, :discount, :id, :num, :remain).order("mall_id,quota desc").offset(page * 30).limit(30)
      data = {status: 1, result: coupons}
      render json: data, callback: params[:callback]
      $dcl.set(key, data) if coupons.size > 0
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

  def jd_miaosha
    begin
      action_params = {
        apikey: $mayi_key,
        cid3: params[:cid] || 655,
        sortName: "inOrderCount30Days",
        isBeginSecKill: 0,
        pageSize: 30
      }
      if params[:owner] == 'p' || params[:owner] == 'g'
        owner = params[:owner]
        action_params[:owner] = params[:owner]
      else
        owner = ''
      end
      key = Digest::MD5.hexdigest("jdmiaosha_#{action_params[:cid3]}_#{owner}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      uri = URI("http://api-gw.haojingke.com/index.php/v1/api/jd/getseckill")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = action_params.to_json
      response = http.request(request)
      data = response.body
      render json: data, callback: params[:callback]
      $dcl.set(key, data)
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def authority_query
    begin
      action_params = {
        pid: params[:pid]
      }
      qq = system_params("pdd.ddk.member.authority.query").merge(action_params)
      response = do_request(qq)
      data = JSON.parse(response.body)
      render json: data, callback: params[:callback]
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def authority_generate
    begin
      action_params = {
        p_id: params[:pid],
        goods_sign_list: '["c9r2omogKFFAc7WBwvbZU1ikIb16_J3CTa8HNN"]',
        generate_authority_url: true
      }
      qq = system_params("pdd.ddk.goods.promotion.url.generate").merge(action_params)
      response = do_request(qq)
      data = JSON.parse(response.body)
      render json: data, callback: params[:callback]
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

end
