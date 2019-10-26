require 'net/http'
require 'lanlan_api' 
require 'uuhaodian'
class UuController < ApplicationController
  skip_before_action :verify_authenticity_token
  def hot_keywords
    render json: lanlan_hot_search_keywords
  end
  def home_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    cid = params[:cid].nil? ? 0 : params[:cid].to_i
    sort = params[:sort].nil? ? 7 : params[:sort].to_i
    render json: lanlan_coupon_list(cid, sort, page, 20), callback: params[:callback]
  end

  def product
    render json: lanlan_coupon_detail(params[:item_id])
  end

  def product_db
    item_id = params[:item_id].to_i
    if item_id.zero?
      render json: {status: 0}
      return
    end
    product = Product.where(item_id: item_id).take
    detail = ProductDetail.where(item_id: item_id).take
    coupon = ProductCoupon.where(item_id: item_id).order("id desc").take
    if product.nil? || detail.nil?
      render json: {status: 0}
      return
    end
    render json: {status:{code: 1001, msg: "ok"}, result: {
        itemId: item_id.to_s,
        title: product.title,
        shortTitle: detail.short_title,
        recommend: detail.description,
        price: product.price,
        nowPrice: coupon.nil? ? product.price : (product.price - coupon.price),
        monthSales: detail.month_sales,
        sales2h: detail.sales_2h,
        sellerName: product.nick,
        sellerId: product.seller_id,
        category: detail.category,
        shopType: product.is_tmall == 1 ? "tmall" : "taobao",
        coverImage: detail.cover_url,
        auctionImages: JSON.parse(product.small_images),
        detailImages: JSON.parse(detail.detail_images),
        couponUrl: coupon.nil? ? "" : ("activityId=" + coupon.activity_id),
        couponMoney: coupon.nil? ? 0 : coupon.price,
        couponEndTime: coupon.nil? ? 0 : coupon.end_time
    }}
  end

  def product_qixiu
    begin
      id = params[:id].to_i
      key = Digest::MD5.hexdigest("qixiuproduct_#{id}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      product = QixiuProduct.where(id: id).take
      if product.nil?
        render json: {status: 0}
        return
      end
      ps = QixiuProduct.where("id > ?", product.id).select(:id, :title, :price, :pict_url).order("id").limit(20).to_a
      data = {status: 1, result: {
        itemId: product.item_id.to_s,
        title: product.title,
        shortTitle: product.title,
        keywords: product.keywords,
        recommend: "",
        provcity: product.provcity,
        nick: product.nick,
        price: product.o_price,
        nowPrice: product.price,
        monthSales: product.volume,
        sales2h: product.volume,
        sellerName: product.nick,
        sellerId: product.seller_id,
        shopType: product.is_tmall == 1 ? "tmall" : "taobao",
        coverImage: product.pict_url,
        auctionImages: JSON.parse(product.pics),
        detailImages: [],
        couponUrl: "",
        couponMoney: 0,
        couponEndTime: 0,
        related: ps
      }}
      render json: data
      $dcl.set(key, data.to_json)
    rescue
      render json: {status: 0}
    end
  end
  def product_meizhuang
    begin
      id = params[:id].to_i
      key = Digest::MD5.hexdigest("meizhuangproduct_#{id}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      product = MeizhuangProduct.where(id: id).take
      if product.nil?
        render json: {status: 0}
        return
      end
      ps = MeizhuangProduct.where("id > ?", product.id).select(:id, :title, :price, :pict_url).order("id").limit(20).to_a
      data = {status: 1, result: {
        itemId: product.item_id.to_s,
        title: product.title,
        shortTitle: product.title,
        keywords: product.keywords,
        recommend: "",
        provcity: product.provcity,
        nick: product.nick,
        price: product.o_price,
        nowPrice: product.price,
        monthSales: product.volume,
        sales2h: product.volume,
        sellerName: product.nick,
        sellerId: product.seller_id,
        shopType: product.is_tmall == 1 ? "tmall" : "taobao",
        coverImage: product.pict_url,
        auctionImages: JSON.parse(product.pics),
        detailImages: [],
        couponUrl: "",
        couponMoney: 0,
        couponEndTime: 0,
        related: ps
      }}
      render json: data
      $dcl.set(key, data.to_json)
    rescue
      render json: {status: 0}
    end
  end

  def product_peishi
    begin
      id = params[:id].to_i
      key = Digest::MD5.hexdigest("peishiproduct_#{id}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      product = PeishiProduct.where(id: id).take
      if product.nil?
        render json: {status: 0}
        return
      end
      ps = PeishiProduct.where("id > ?", product.id).select(:id, :title, :price, :pict_url).order("id").limit(20).to_a
      data = {status: 1, result: {
        itemId: product.item_id.to_s,
        title: product.title,
        shortTitle: product.title,
        keywords: product.keywords,
        recommend: "",
        provcity: product.provcity,
        nick: product.nick,
        price: product.o_price,
        nowPrice: product.price,
        monthSales: product.volume,
        sales2h: product.volume,
        sellerName: product.nick,
        sellerId: product.seller_id,
        shopType: product.is_tmall == 1 ? "tmall" : "taobao",
        coverImage: product.pict_url,
        auctionImages: JSON.parse(product.pics),
        detailImages: [],
        couponUrl: "",
        couponMoney: 0,
        couponEndTime: 0,
        related: ps
      }}
      render json: data
      $dcl.set(key, data.to_json)
    rescue
      render json: {status: 0}
    end
  end

  def product_yumaoqiu
    begin
      id = params[:id].to_i
      key = Digest::MD5.hexdigest("ymqproduct_#{id}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      product = YmqProduct.where(id: id).take
      if product.nil?
        render json: {status: 0}
        return
      end
      ps = YmqProduct.where("id > ?", product.id).select(:id, :title, :price, :pict_url).order("id").limit(20).to_a
      data = {status: 1, result: {
        itemId: product.item_id.to_s,
        title: product.title,
        shortTitle: product.title,
        keywords: product.keywords,
        recommend: "",
        provcity: product.provcity,
        nick: product.nick,
        price: product.o_price,
        nowPrice: product.price,
        monthSales: product.volume,
        sales2h: product.volume,
        sellerName: product.nick,
        sellerId: product.seller_id,
        shopType: product.is_tmall == 1 ? "tmall" : "taobao",
        coverImage: product.pict_url,
        auctionImages: JSON.parse(product.pics),
        detailImages: [],
        couponUrl: "",
        couponMoney: 0,
        couponEndTime: 0,
        related: ps
      }}
      render json: data
      $dcl.set(key, data.to_json)
    rescue
      render json: {status: 0}
    end
  end

  def product_cailiao
    begin
      id = params[:id].to_i
      key = Digest::MD5.hexdigest("cailiaoproduct_#{id}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      product = CailiaoProduct.where(id: id).take
      if product.nil?
        render json: {status: 0}
        return
      end
      ps = CailiaoProduct.where("id > ?", product.id).select(:id, :title, :price, :pict_url).order("id").limit(20).to_a
      data = {status: 1, result: {
        itemId: product.item_id.to_s,
        title: product.title,
        shortTitle: product.title,
        keywords: product.keywords,
        recommend: "",
        provcity: product.provcity,
        nick: product.nick,
        price: product.o_price,
        nowPrice: product.price,
        monthSales: product.volume,
        sales2h: product.volume,
        sellerName: product.nick,
        sellerId: product.seller_id,
        shopType: product.is_tmall == 1 ? "tmall" : "taobao",
        coverImage: product.pict_url,
        auctionImages: JSON.parse(product.pics),
        detailImages: [],
        couponUrl: "",
        couponMoney: 0,
        couponEndTime: 0,
        related: ps
      }}
      render json: data
      $dcl.set(key, data.to_json)
    rescue
      render json: {status: 0}
    end
  end
  def product_shipin
    begin
      id = params[:id].to_i
      key = Digest::MD5.hexdigest("shipinproduct_#{id}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      product = ShipinProduct.where(id: id).take
      if product.nil?
        render json: {status: 0}
        return
      end
      ps = ShipinProduct.where("id > ?", product.id).select(:id, :title, :price, :pict_url).order("id").limit(20).to_a
      data = {status: 1, result: {
        itemId: product.item_id.to_s,
        title: product.title,
        shortTitle: product.title,
        keywords: product.keywords,
        recommend: "",
        provcity: product.provcity,
        nick: product.nick,
        price: product.o_price,
        nowPrice: product.price,
        monthSales: product.volume,
        sales2h: product.volume,
        sellerName: product.nick,
        sellerId: product.seller_id,
        shopType: product.is_tmall == 1 ? "tmall" : "taobao",
        coverImage: product.pict_url,
        auctionImages: JSON.parse(product.pics),
        detailImages: [],
        couponUrl: "",
        couponMoney: 0,
        couponEndTime: 0,
        related: ps
      }}
      render json: data
      $dcl.set(key, data.to_json)
    rescue
      render json: {status: 0}
    end
  end
  def product_jiankang
    begin
      id = params[:id].to_i
      key = Digest::MD5.hexdigest("jiankangproduct_#{id}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      product = JiankangProduct.where(id: id).take
      if product.nil?
        render json: {status: 0}
        return
      end
      ps = JiankangProduct.where("id > ?", product.id).select(:id, :title, :price, :pict_url).order("id").limit(20).to_a
      data = {status: 1, result: {
        itemId: product.item_id.to_s,
        title: product.title,
        shortTitle: product.title,
        keywords: product.keywords,
        recommend: "",
        provcity: product.provcity,
        nick: product.nick,
        price: product.o_price,
        nowPrice: product.price,
        monthSales: product.volume,
        sales2h: product.volume,
        sellerName: product.nick,
        sellerId: product.seller_id,
        shopType: product.is_tmall == 1 ? "tmall" : "taobao",
        coverImage: product.pict_url,
        auctionImages: JSON.parse(product.pics),
        detailImages: [],
        couponUrl: "",
        couponMoney: 0,
        couponEndTime: 0,
        related: ps
      }}
      render json: data
      $dcl.set(key, data.to_json)
    rescue
      render json: {status: 0}
    end
  end
  def product_tb
    begin
      item_id = params[:item_id].to_i
      need_coupon = params[:need_coupon] ? 1 : 0
      key = Digest::MD5.hexdigest("tbitem_#{item_id}_#{need_coupon}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      Timeout::timeout(2){
        data = product_tb_data(item_id, need_coupon)
        render json: data, callback: params[:callback]
        $dcl.set(key, data.to_json)
      }
    rescue Exception => ex
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def product_tb_data(item_id, need_coupon)
    item_result = get_tbk_item_info_json(item_id)
    if item_result && item_result["tbk_item_info_get_response"]["results"]  && item_result["tbk_item_info_get_response"]["results"]["n_tbk_item"] && item_result["tbk_item_info_get_response"]["results"]["n_tbk_item"].size > 0
      detail = item_result["tbk_item_info_get_response"]["results"]["n_tbk_item"].first
      imgs = []
      if detail["small_images"] && detail["small_images"]["string"]
        imgs = detail["small_images"]["string"]
      end
      coupon_money = 0
      coupon_end_time = 0
      if need_coupon
        result = apply_high_commission(params[:item_id].to_i, $default_sid, $default_pid)
        if result["coupon_info"]
          coupon_money = result["coupon_info"].match(/减(\d+)元/)[1].to_i
          dd = result["coupon_end_time"].split('-')
          coupon_end_time = Time.new(dd[0].to_i, dd[1].to_i, dd[2].to_i).to_i
        end
      end
      return {status:{code: 1001, msg: "ok"}, result: {
        itemId: item_id.to_s,
        title: detail["title"],
        shortTitle: detail["title"],
        recommend: "",
        price: detail["reserve_price"].to_f,
        nowPrice: detail["zk_final_price"].to_f - coupon_money,
        monthSales: detail["volume"].to_i,
        sales2h: detail["volume"].to_i,
        sellerName: detail["nick"],
        sellerId: detail["seller_id"],
        category: detail["cat_name"],
        shopType: detail["user_type"].to_i == 1 ? "tmall" : "taobao",
        coverImage: detail["pict_url"],
        auctionImages: imgs,
        detailImages: [],
        couponUrl: "",
        couponMoney: coupon_money,
        couponEndTime: coupon_end_time 
      }}
    end
    return {status: 0}
  end

  def product_tbs
    if params[:item_ids].nil? || params[:item_ids].empty?
      render json: {status: 0}
      return
    end
    item_ids = params[:item_ids].split(',')
    item_result = get_tbk_items_info_json(item_ids)
    if item_result && item_result["tbk_item_info_get_response"]["results"]  && item_result["tbk_item_info_get_response"]["results"]["n_tbk_item"] && item_result["tbk_item_info_get_response"]["results"]["n_tbk_item"].size > 0
      details = item_result["tbk_item_info_get_response"]["results"]["n_tbk_item"]
      if details.size > 0
        render json: {status: 2, result: details}
        return
      end
    end
    render json: {status: 0}
  end

  def goods_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    keyword = params[:keyword]
    sort = params[:sort].nil? ? 7 : params[:sort].to_i
    render json: lanlan_search_coupon_list(keyword, sort, 0, page, 20), callback: params[:callback]
  end

  def dg_goods_list
    begin
      page = params[:page].nil? ? 1 : params[:page].to_i
      keyword = params[:keyword].gsub('+', '') if params[:keyword]
      if params[:is_simple]
        key = Digest::MD5.hexdigest("dggoodslist_#{keyword}_#{page}")
        if result = $dcl.get(key)
          render json: result, callback: params[:callback]
          return
        end
        data = dg_goods_list_data(page, keyword, nil, "tk_total_commi_des", nil, nil, nil, nil, nil, nil, nil, nil)
        render json: data, callback: params[:callback]
        $dcl.set(key, data.to_json)
        return
      end
      is_tmall = params[:is_tmall] == "1" ? true : nil
      is_overseas = params[:is_overseas] == "1" ? true : nil
      has_coupon = params[:has_coupon] == "1" ? true : nil
      data = dg_goods_list_data(page, keyword, params[:cat], params[:sort], is_tmall, is_overseas, has_coupon, params[:start_dsr], params[:start_tk_rate], params[:end_tk_rate], params[:start_price], params[:end_price])
      render json: data, callback: params[:callback]
    rescue Exception => ex
      render json: {status: 0}, callback: params[:callback]
    end
  end
  
  def dg_goods_list_data(page, keyword, cat, sort, is_tmall, is_overseas, has_coupon, start_dsr, start_tk_rate, end_tk_rate, start_price, end_price)
    dg_material_result = get_tbk_dg_material_json_only_search(keyword, cat, sort, is_tmall, is_overseas, has_coupon, start_dsr, start_tk_rate, end_tk_rate, start_price, end_price, page)
    if dg_material_result && dg_material_result["tbk_dg_material_optional_response"]["result_list"] && dg_material_result["tbk_dg_material_optional_response"]["result_list"]["map_data"].size > 0 
      result = dg_material_result["tbk_dg_material_optional_response"]["result_list"]["map_data"].map do |item|
        item.delete("item_url")
        item.delete("num_iid")
        item.delete("coupon_share_url")
        item.delete("small_images")
        item.delete("info_dxjh")
        item.delete("include_mkt")
        item.delete("include_dxjh")
        item
      end
      return {status: 1, results: result}
    end
    return {status: 0}
  end

  def item_channel_url_data(title, item_id, aid)
    dg_material_result = get_tbk_dg_material_json(title, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 1, aid)
    if dg_material_result && dg_material_result["tbk_dg_material_optional_response"] && dg_material_result["tbk_dg_material_optional_response"]["result_list"] && dg_material_result["tbk_dg_material_optional_response"]["result_list"]["map_data"].size > 0 
      result = dg_material_result["tbk_dg_material_optional_response"]["result_list"]["map_data"].map do |item|
        if item["item_id"].to_i == item_id.to_i
          return item["coupon_share_url"] || item["url"]
        end
      end
    end
    return ""
  end

  def tb_goods_list
    begin
      page = params[:page].nil? ? 1 : params[:page].to_i
      keyword = params[:keyword].gsub('+', '')
      key = Digest::MD5.hexdigest("tbgoodslist_#{keyword}_#{page}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      Timeout::timeout(2){
        data = tb_goods_list_data(page, keyword)
        render json: data, callback: params[:callback]
        $dcl.set(key, data.to_json)
      }
    rescue Exception => ex
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def tb_goods_list_data(page, keyword)
    tb_coupon_result = get_tbk_coupon_search_json(keyword, 218532065, page)
    if tb_coupon_result && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]  && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]["tbk_coupon"] && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]["tbk_coupon"].size > 0
      data = {status: 1, results: tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]["tbk_coupon"]}
      return data
    end
    tb_result = get_tbk_search_json(keyword, page)
    if tb_result && tb_result["tbk_item_get_response"]["total_results"] > 0
      data = {status: 2, results: tb_result["tbk_item_get_response"]["results"]["n_tbk_item"]}
      return data
    end
    return {status: 0}
  end

  def tb_goods_item_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    keyword = params[:keyword].nil? ? nil : params[:keyword].gsub('+', '')
    cat = params[:cat]
    is_tmall = params[:is_tmall]
    sort = params[:sort]
    start_price = params[:start_price].nil? ? 0 : params[:start_price]
    end_price = params[:end_price].nil? ? 99999 : params[:end_price]
    tb_result = get_tbk_search_json_new(keyword, page, cat, sort, is_tmall, start_price, end_price)
    if tb_result && tb_result["tbk_item_get_response"]["total_results"] > 0
      data = {status: 2, results: tb_result["tbk_item_get_response"]["results"]["n_tbk_item"]}
      render json: data, callback: params[:callback]
      return
    end
    render json: {status: 0}, callback: params[:callback]
  end

  def tb_goods_recommend
    begin
      item_id = params[:item_id]
      key = Digest::MD5.hexdigest("tbgoodsrecommend_#{item_id}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      Timeout::timeout(2){
        data = tb_goods_recommend_data(item_id)
        render json: data, callback: params[:callback]
        $dcl.set(key, data.to_json)
      }
    rescue Exception => ex
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def tb_goods_recommend_data(item_id)
    tb_coupon_result = get_tbk_recommend_json(item_id)
    if tb_coupon_result && tb_coupon_result["tbk_item_recommend_get_response"]["results"]  && tb_coupon_result["tbk_item_recommend_get_response"]["results"]["n_tbk_item"] && tb_coupon_result["tbk_item_recommend_get_response"]["results"]["n_tbk_item"].size > 0
      data = {status: 2, results: tb_coupon_result["tbk_item_recommend_get_response"]["results"]["n_tbk_item"]}
      return data
    end
    return {status: 0}
  end

  def tb_dg_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    material_id = params[:cid]
    tb_dg_result = get_tbk_dg_list_json(material_id, page)
    if tb_dg_result && tb_dg_result["tbk_dg_optimus_material_response"]["result_list"] && tb_dg_result["tbk_dg_optimus_material_response"]["result_list"]["map_data"] && tb_dg_result["tbk_dg_optimus_material_response"]["result_list"]["map_data"].size > 0
      data = {status: 1, results: tb_dg_result["tbk_dg_optimus_material_response"]["result_list"]["map_data"]}
      render json: data, callback: params[:callback]
      return
    end
    render json: {status: 0}, callback: params[:callback]
  end

  def category_list
    render json: lanlan_category_list
  end

  def jiukuaijiu_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    cid = params[:cid].nil? ? 0 : params[:cid].to_i
    render json: lanlan_type_coupon_list(4, cid, 1, page, 20), callback: params[:callback]
  end

  def temai_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    cid = params[:cid].nil? ? 0 : params[:cid].to_i
    render json: lanlan_type_coupon_list(1, cid, 1, page, 20), callback: params[:callback]
  end

  def sale_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    cid = params[:cid].nil? ? 0 : params[:cid].to_i
    render json: lanlan_type_coupon_list(2, cid, 1, page, 20), callback: params[:callback]
  end

  def brand_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    cid = params[:cid].nil? ? 0 : params[:cid].to_i
    render json: lanlan_type_coupon_list(3, cid, 1, page, 20), callback: params[:callback]
  end

  def user_login
      url = "https://api.weixin.qq.com/sns/jscode2session?appid=wx80e26f4dc3534b2d&secret=26d4b6321b80a52cc5df1350d0c631ac&js_code=#{params[:code]}&grant_type=authorization_code"
      result = Net::HTTP.get(URI(URI.encode(url)))
      data = JSON.parse(result)
      user = UuUser.where(open_id: data["openid"]).take || UuUser.new
      user.open_id = data["openid"]
      user.session_key = data["session_key"]
      user.union_id = data["unionid"] || ''
      user.save
      render json: {user_id: user.id, session_key: user.session_key}
  end

  def add_user_info
    user = UuUser.where(id: params[:user_id].to_i, session_key: params[:session_key]).take
    if user.nil?
      render json: {status: -1}
      return
    end
    data_1 =  JSON.parse(params[:user_info])
    detail = UuUserDetail.where(user_id: user.id).take || UuUserDetail.new
    detail.user_id = user.id
    detail.name = data_1["nickName"]
    detail.headimgurl = data_1["avatarUrl"]
    detail.sex = data_1["gender"]
    detail.language = data_1["language"]
    detail.city = data_1["city"]
    detail.province = data_1["province"]
    detail.country = data_1["country"]
    detail.save
    render json: {status: 1}
  end

  def add_user_score
    user = UuUser.where(id: params[:user_id].to_i, session_key: params[:session_key]).take
    if user.nil?
      render json: {status: -1}
      return
    end
    detail = UuUserDetail.where(user_id: user.id).take
    if detail.nil?
      render json: {status: -1}
      return
    end
    detail.score = params[:score]
    detail.save
    render json: {status: 1}
  end

  def get_user_info
    detail = UuUserDetail.where(user_id: params[:user_id]).take
    render json: {
      nickName: detail.name,
      gender: detail.sex,
      avatarUrl: detail.headimgurl,
      score: JSON.parse(detail.score)
    }
  end

  def add_user_review
    user = UuUser.where(id: params[:review_user_id].to_i, session_key: params[:session_key]).take
    if user.nil?
      render json: {status: -1}
      return
    end
    r = UuUserReview.new
    r.user_id = params[:user_id].to_i
    r.review_user_id = user.id
    r.name = params[:nickName]
    r.headimgurl = params[:avatarUrl]
    r.content = params[:content]
    r.r_content = '' 
    r.save
    render json: {status: 1}
  end

  def user_review_reply
    user = UuUser.where(id: params[:user_id].to_i, session_key: params[:session_key]).take
    if user.nil?
      render json: {status: -1}
      return
    end
    r = UuUserReview.where(id: params[:review_id].to_i, user_id: user.id).take
    if r.nil?
      render json: {status: -1}
      return
    end
    r.r_content = params[:r_content]
    r.save
    render json: {status: 1}
  end

  def get_user_review
    reviews = UuUserReview.where(user_id: params[:user_id].to_i).select(:id, :name, :headimgurl, :content, :r_content, :created_at, :updated_at).order("id desc").to_a
    render json: reviews
  end

  def post_message
    render plain: "success"
    begin
      item_id = params[:SessionFrom]
      if !item_id.nil? && m = item_id.match(/detail_(\d+)/)
        item_id = m[1].to_i
        detail = JSON.parse(lanlan_coupon_detail(item_id))
        token = UuToken.take.token
        url = "https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{token}"
        qq = {
          "touser" => params[:FromUserName],
          "msgtype" => "link",
          "link" => {
            "title" => "#{detail["result"]["couponMoney"].to_i}元优惠券",
            "description" => detail["result"]["shortTitle"],
            "url" => "https://api.uuhaodian.com/uu/detail_redirect/#{item_id}",
            "thumb_url" => detail["result"]["coverImage"]
          }
        }
        uri = URI(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
        request.body = qq.to_json
        response = http.request(request)
      end
    rescue
      puts "ERROR: post_message #{item_id}"
    end
  end

  def check_post_message
    arr = ['uuapi', params[:timestamp], params[:nonce]].sort
    tmp_str = arr.join('')
    key = Digest::SHA1.hexdigest(tmp_str)
    puts params[:signature]
    if key == params[:signature]
      render plain: params[:echostr] || params[:echoStr]
    else
      render plain: "fail"
    end
  end

  def detail_redirect
    redirect_to "http://wap.uuhaodian.com/saber/detail?itemId=#{params[:id]}&pid=mm_32854514_34792441_314020343&forCms=1&super=1", status: 302
  end


  def inreview
    begin
      render json: {in_review: params[:version] == '1.5.0'}
    rescue
      render json: {in_review: false}
    end
  end

  def apply_high_commission(product_id, sid, pid)
    url = "https://www.heimataoke.com/api-zhuanlian?appkey=#{$heima_appkey}&appsecret=#{$heima_appsecret}&sid=#{sid}&pid=#{pid}&num_iid=#{product_id}"
    JSON.parse(Net::HTTP.get(URI(url)))
  end

  def newbuy
      if is_robot?
        render plain: "https://detail.taobao.com/item.htm?id=#{params[:id]}"
        return
      end
      result = ""
      if channel = get_channel
        result = item_channel_url_data(params[:title], params[:id], channel.aid)
      else
        result = item_channel_url_data(params[:title], params[:id], $default_aid)
      end
      if result.empty?
        redirect_to "/uu/buy?id=#{params[:id]}&xcx=#{params[:xcx]}&channel=#{params[:channel]}"
        return
      end
      if params[:xcx]
        render plain: result
        return
      else
        redirect_to result, status: 302
      end
  end

  def buy
    begin
      if is_robot?
        render plain: "https://detail.taobao.com/item.htm?id=#{params[:id]}"
        return
      end
      if params[:xcx] && params[:channel].to_i == 12
        render plain: ''
        return
      end
      url = "https://detail.taobao.com/item.htm?id=#{params[:id]}"
      if channel = get_channel
        result = apply_high_commission(params[:id], channel.sid, channel.pid)
      else
        result = apply_high_commission(params[:id], $default_sid, $default_pid)
      end
      url = result["coupon_click_url"] unless result["coupon_click_url"].nil?
      if params[:xcx]
        render plain: url
        return
      else
        redirect_to url, status: 302
      end
    rescue
    end
  end

  def get_channel
    if params[:channel].nil?
      return nil
    end
    if $uu_channels.nil? || (Time.now.to_i - $uu_channels_update) > 3600
      $uu_channels = UuChannel.all.to_a
      $uu_channels_update = Time.now.to_i
    end
    $uu_channels.each do |c|
      return c if c.id == params[:channel].to_i
    end
    nil
  end
  def pcbuy
    begin
      url = "https://detail.taobao.com/item.htm?id=#{params[:id]}"
      if channel = get_channel
        result = apply_high_commission(params[:id], channel.sid, channel.pid)
      else
        result = apply_high_commission(params[:id], $default_sid, $default_pid)
      end
      url = result["coupon_click_url"] unless result["coupon_click_url"].nil?
      url += "&activityId=#{params[:activity_id]}" if params[:activity_id]
      redirect_to url, status: 302
    rescue
    end
  end

  def get_tbk_dg_material_json(keyword, cat, sort, is_tmall, is_overseas, has_coupon, start_dsr, start_tk_rate, end_tk_rate, start_price, end_price, page_no, aid = $taobao_adzone_id_material)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_dg_material_optional(keyword, cat, sort, is_tmall, is_overseas, has_coupon, start_dsr, start_tk_rate, end_tk_rate, start_price, end_price, '6707', $taobao_app_id_material, $taobao_app_secret_material, aid, page_no, 20 ))
  end

  def get_tbk_dg_material_json_only_search(keyword, cat, sort, is_tmall, is_overseas, has_coupon, start_dsr, start_tk_rate, end_tk_rate, start_price, end_price, page_no, aid = $taobao_adzone_id_material_only_search_1)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_dg_material_optional(keyword, cat, sort, is_tmall, is_overseas, has_coupon, start_dsr, start_tk_rate, end_tk_rate, start_price, end_price, '6707', $taobao_app_id_material_only_search_1, $taobao_app_secret_material_only_search_1, aid, page_no, 20 ))
  end

  def get_tbk_search_json(keyword, page_no)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_item_get(keyword, $taobao_app_id, $taobao_app_secret, page_no,50))
  end

  def get_tbk_search_json_new(keyword, page_no, cat = nil, sort = nil, is_tmall = nil, start_price = 0, end_price = 99999)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_item_get_new(keyword, cat, sort, is_tmall, start_price, end_price, $taobao_app_id, $taobao_app_secret, page_no,20))
  end

  def get_tbk_coupon_search_json(keyword, adzone, page_no)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_dg_item_coupon_get(keyword, adzone, $taobao_app_id, $taobao_app_secret, page_no,50))
  end

  def get_tbk_recommend_json(item_id, page_size = 20)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_item_recommend_get(item_id, $taobao_app_id, $taobao_app_secret,page_size))
  end

  def get_tbk_dg_list_json(material_id, page_no, page_size = 20)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_dg_optimus_material($taobao_adzone_id, $taobao_app_id, $taobao_app_secret, material_id, page_no, page_size))
  end

  def get_tbk_item_info_json(item_id)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_item_info_get([item_id], $taobao_app_id, $taobao_app_secret))
  end

  def get_tbk_items_info_json(item_ids)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_item_info_get(item_ids, $taobao_app_id, $taobao_app_secret))
  end

  def get_tbk_items_detail_json(item_ids)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_items_detail_get(item_ids, $taobao_app_id, $taobao_app_secret))
  end

  def game_list
    page = params[:page] || 0
    page = page.to_i
    games = Game.select(:title, :img_url, :price, :s_record, :s_win, :s_mac, :s_linux, :released_time).order(:id).offset(25 * page).limit(25)
    render json: {status: 1001, result: games}
  end

  def mkq_list
    coupons = MkqCoupon.where(brand_id: params[:id].to_i).select(:id, :title, :img_url, :time_to, :description).to_a
    render json: {status: 1001, result: coupons}
  end

  def mkq_detail
    coupon = MkqCoupon.where(id: params[:id].to_i).take
    render json: {status: 1001, result: coupon}
  end

  def banners
    bs = Banner.where(status: 1).select(:id, :link_url, :img_url).order("id desc").limit(5)
    render json: {status: 1001, result: bs.to_a}
  end

  def create_tbwd
    if is_robot?
      render json: {status: 0}
      return
    end
    tbk = Tbkapi::Taobaoke.new
    result = JSON.parse(tbk.taobao_tbk_tpwd_create(params[:url],params[:content].gsub('+',' '), $taobao_app_id, $taobao_app_secret, params[:logo], params[:user_id]))
    if result["tbk_tpwd_create_response"] && result["tbk_tpwd_create_response"]["data"] && result["tbk_tpwd_create_response"]["data"]["model"]
      render json: {status: 1001, result: result["tbk_tpwd_create_response"]["data"]["model"]}
    else
      render json: {status: 0}
    end
  end

  def query_tbwd
    tbk = Tbkapi::Taobaoke.new
    result = JSON.parse(tbk.taobao_wireless_share_tpwd_query(params[:tbwd], $taobao_app_id, $taobao_app_secret))
    if result["wireless_share_tpwd_query_response"]
      render json: {status: 1001, result: result["wireless_share_tpwd_query_response"]}
    else
      render json: {status: 0}
    end
  end

  def check_product_liked
    if cookies[:session_key].nil? || cookies[:session_key].empty?
      render json: {status: 0}, callback: params[:callback]
      return
    end
    user_id = 0
    user = WebUser.where(session_key: cookies[:session_key]).take
    user_id = user.id unless  user.nil?
    item_id = params[:item_id].to_i
    if user_id.zero? || item_id.zero?
      render json: {status: 0}, callback: params[:callback]
      return
    end
    render json: {status: Liked.exists?(user_id: user_id, item_id: item_id) ? 1 : 0}, callback: params[:callback]
  end

  def add_product_liked
    if cookies[:session_key].nil? || cookies[:session_key].empty?
      render json: {status: 0}, callback: params[:callback]
      return
    end
    user_id = 0
    user = WebUser.where(session_key: cookies[:session_key]).take
    user_id = user.id unless  user.nil?
    item_id = params[:item_id].to_i
    if user_id.zero? || item_id.zero?
      render json: {status: 0}, callback: params[:callback]
      return
    end
    begin
      liked = Liked.new
      liked.user_id = user_id
      liked.item_id = item_id
      liked.save
      unless MonitorProduct.exists?(item_id: item_id)
        monitor = MonitorProduct.new
        monitor.item_id = item_id
        monitor.save
      end
    ensure
      render json: {status: 1}, callback: params[:callback]
    end
  end

  def cancel_product_liked
    if cookies[:session_key].nil? || cookies[:session_key].empty?
      render json: {status: 0}, callback: params[:callback]
      return
    end
    user_id = 0
    user = WebUser.where(session_key: cookies[:session_key]).take
    user_id = user.id unless  user.nil?
    item_id = params[:item_id].to_i
    if user_id.zero? || item_id.zero?
      render json: {status: 0}, callback: params[:callback]
      return
    end
    begin
      Liked.destroy_all(user_id: user_id, item_id: item_id)
    ensure
      render json: {status: 1}, callback: params[:callback]
    end
  end

  def get_product_liked
    if cookies[:session_key].nil? || cookies[:session_key].empty?
      render json: {status: 0}, callback: params[:callback]
      return
    end
    user_id = 0
    user = WebUser.where(session_key: cookies[:session_key]).take
    user_id = user.id unless  user.nil?
    page = params[:page] || 1
    page = page.to_i - 1
    if user_id.zero?
      render json: {status: 0}, callback: params[:callback]
      return
    end
    liked = Liked.where(user_id: user_id).select(:id,:item_id).order("id desc").offset(20 * page).limit(20).to_a
    item_ids = liked.map{|item| item.item_id}
    products = Product.where(item_id: item_ids).select(:item_id, :price,:is_tmall).to_a
    details = ProductDetail.where(item_id: item_ids).select(:item_id, :short_title, :month_sales, :cover_url).to_a
    coupons = ProductCoupon.where(item_id: item_ids).select(:id, :item_id, :price, :end_time)

    result = []
    products.each do |pd|
      detail = details.select{|item| item.item_id == pd.item_id}.first
      next if detail.nil?
      coupon = coupons.select{|item| item.item_id == pd.item_id}.first
      next if coupon.nil?
      item = {}
      item[:itemId] = pd.item_id
      item[:shortTitle] = detail.short_title 
      item[:monthSales] = detail.month_sales
      item[:coverImage] = detail.cover_url
      item[:price] = pd.price
      item[:nowPrice] = pd.price - coupon.price
      item[:couponMoney] = coupon.price
      item[:shopType] = pd.is_tmall == 1 ? "tmall" : "taobao"
      result << item
    end
    render json: {status: {code: 1001, msg: "ok"}, result: result}, callback: params[:callback]
  end

  def web_login
    begin
      url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{$wx_app_key}&secret=#{$wx_app_secret}&code=#{params[:code]}&grant_type=authorization_code"
      result = Net::HTTP.get(URI(URI.encode(url)))
      data = JSON.parse(result)
      if data["openid"].nil?
        redirect_to "http://www.uuhaodian.com", status: 302
        return
      end
      url_1 = "https://api.weixin.qq.com/sns/userinfo?access_token=#{data["access_token"]}&openid=#{data["openid"]}"
      result_1 = Net::HTTP.get(URI(URI.encode(url_1)))
      data_1 = JSON.parse(result_1)
      #set cookies | redirect | save to db
      session_key = data_1["openid"][0,10] + Time.now.to_i.to_s
      cookies[:nickname] ={
        value: data_1["nickname"],
        expires: 7.day.from_now,
        domain: 'uuhaodian.com'
      }
      cookies[:headimgurl] ={
        value: data_1["headimgurl"],
        expires: 7.day.from_now,
        domain: 'uuhaodian.com'
      }
      cookies[:session_key] ={
        value: session_key,
        expires: 7.day.from_now,
        domain: 'uuhaodian.com'
      }
      redirect_to "#{params[:uu_path].nil? ? "http://www.uuhaodian.com" : params[:uu_path]}", status: 302
      user = WebUser.where(open_id: data["openid"]).take || WebUser.new
      user.open_id = data["openid"]
      user.union_id = data["unionid"]
      user.access_token = data["access_token"]
      user.session_key = session_key
      user.save
      detail = WebUserDetail.where(user_id: user.id).take || WebUserDetail.new
      detail.user_id = user.id
      detail.name = data_1["nickname"]
      detail.headimgurl = data_1["headimgurl"]
      detail.sex = data_1["sex"]
      detail.language = data_1["language"]
      detail.city = data_1["city"]
      detail.province = data_1["province"]
      detail.country = data_1["country"]
      detail.save
    rescue
      redirect_to "#{params[:uu_path].nil? ? "http://www.uuhaodian.com" : params[:uu_path]}", status: 302
    end
  end

  def web_logout
    user = WebUser.where(session_key: cookies[:session_key]).take
    if user.nil?
      redirect_to "http://www.uuhaodian.com", status: 302
      return
    end
    cookies.delete(:nickname, :domain => 'uuhaodian.com')
    cookies.delete(:headimgurl, :domain => 'uuhaodian.com')
    cookies.delete(:session_key, :domain => 'uuhaodian.com')
    redirect_to "http://www.uuhaodian.com", status: 302
    user.session_key = ''
    user.save
  end

  def gzh_reply
    render plain: "success"
    begin
      xml = Nokogiri::XML request.body.read
      if xml.xpath('//MsgType').text == 'text'
        token = UuToken.where(id: 2).take.token
        url = "https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{token}"
        qq = {
          "touser" => xml.xpath('//FromUserName').text,
          "msgtype" => "miniprogrampage",
          "miniprogrampage" =>
          {
            "title" => "优惠券",
            "appid" => "wx80e26f4dc3534b2d",
            "pagepath" => "pages/index/index",
            "thumb_media_id" => 'MG83gcEBg0Yv1BhoD35TlhHbrpV1c5AMa-GE9EpNh62zjS3FzEI3jzs8ck8fKeMx'
          }
        }
        uri = URI(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
        request.body = qq.to_json
        response = http.request(request)
        Rails.logger.info response.body
      end
    rescue
      Rails.logger.fatal "ERROR: gzh_reply"
    end
  end

  def user_group
    session_key = params[:session_key]
    user = UuUser.where(session_key: session_key).take
    if user.nil?
      render json: {status: -1}
      return
    end
    decipher = OpenSSL::Cipher::AES.new(128, :CBC)
    decipher.decrypt
    decipher.key = Base64.decode64(session_key)
    decipher.iv = Base64.decode64(params[:iv])
    data = JSON.parse(decipher.update(Base64.decode64(params[:edata])) + decipher.final)
    group = UuUserGroup.where(group_open_id: data["openGId"], user_id: user.id).take
    if group.nil?
      group = UuUserGroup.new
      group.group_open_id = data["openGId"]
      group.user_id = user.id
      group.save
    end
    render json: {status: 1, openGId: data["openGId"], group_id: group.id}
  end

  def get_my_groups
    user = UuUser.where(id: params[:user_id].to_i, session_key: params[:session_key]).take
    if user.nil?
      render json: {status: -1}
      return
    end
    groups = UuUserGroup.where(user_id: user.id).select(:id, :group_open_id).to_a
    render json: {status: 1, result: groups}
  end

  def get_group_detail
    user_ids = UuUserGroup.where(group_open_id: params[:group_open_id]).pluck(:user_id)
    if user_ids.size.zero?
      render json: {status: -1}
      return
    end
    users = UuUserDetail.where(user_id: user_ids).select(:id, :name, :headimgurl, :score,:user_id)
    result = []
    users.each do |u|
      if u.score == ''
        j = [0]
      else
        j = JSON.parse(u.score)
      end
      sum = j.inject(0){|sum,x| sum + x }
      rank = (sum * 1.0 / 5).floor
      result << {
        id: u.user_id,
        name: u.name,
        headimgurl: u.headimgurl,
        scores: sum,
        rank: rank
      }
    end
    render json: {status: 1, result: result.sort{|a,b| b[:scores] <=> a[:scores]}}
  end

  def video_list
    page = params[:page].nil? ? 0 : params[:page].to_i
    videos = Video.select(:id,:cover_url,:user_avatar,:user_name).offset(20 * page).limit(20).to_a
    if videos.size > 0
      render json: {status: 1, result: videos}
    else
      render json: {status: 0}
    end
  end

  def video
    video = Video.where(id: params[:id].to_i).select(:id, :cover_url, :video_url, :video_desc, :user_name, :user_avatar).take
    if video.nil?
      render json: {status: 0}
      return
    end
    product_ids = VideoProduct.where(video_id: video.id).pluck(:product_id)
    render json: {status: 1, result: {
      video: video,
      product_ids: product_ids
    }}
  end

  def shop
    shop = Shop.where(nick: params[:name]).take
    if shop.nil?
      render json: {status: 0}
      return
    end
    js = JSON.parse(shop.dsr_info)
    render json: {status: 1, result: {
      shop: {
        title: shop.title,
        place: shop.provcity,
        shop_url: shop.shop_url,
        pic_url: shop.pic_url,
        source_id: shop.source_id,
        keyword: shop.search_keyword,
        type: JSON.parse(js["dsrStr"])["ind"]
      }
    }}
  end

  def shop_hot_items
    shop = ShopHotItem.where(shop_source_id: params[:shop_id]).take
    if shop.nil? || shop.item_ids.empty?
      render json: {status: 0}, callback: params[:callback]
      return
    end
    ids = shop.item_ids.split(',')
    item_result = get_tbk_item_info_json(ids)
    if item_result && item_result["tbk_item_info_get_response"]["results"]  && item_result["tbk_item_info_get_response"]["results"]["n_tbk_item"] && item_result["tbk_item_info_get_response"]["results"]["n_tbk_item"].size > 0
      details = item_result["tbk_item_info_get_response"]["results"]["n_tbk_item"]
      if details.size > 0
        render json: {status: 1, result: details}, callback: params[:callback]
        return
      end
    end
    render json: {status: 0}, callback: params[:callback]
  end

  def keyword_infos
    begin
      keyword = params[:keyword]
      if keyword.nil?
        render json: {status: 0}, callback: params[:callback]
        return
      end
      keyword = keyword.strip
      key = Digest::MD5.hexdigest("keywordinfo_#{keyword}")
      if result = $dcl.get(key)
        render json: result, callback: params[:callback]
        return
      end
      Timeout::timeout(2){
        data = get_keyword_infos_data(keyword)
        if data.nil?
          render json: {status: 0}, callback: params[:callback]
          return
        end
        render json: {status: 1, result: data}, callback: params[:callback]
        $dcl.set(key, {status: 1, result: data}.to_json)
      }
    rescue Exception => ex
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def get_keyword_infos_data(keyword)
    k = TbKeyword.where(keyword: keyword, status: 1).take
    if k.nil?
      return nil
    end
    r_k_ids = k.r_keywords1.split(',') + k.r_keywords2.split(',')
    r_ks = TbKeyword.where(id: r_k_ids).pluck(:keyword)
    r_cats = TbCategory.where(source_id: k.r_cats.split(',')).select(:id, :source_id, :name).to_a
    selector = nil
    if k.has_selector == 1
      s = TbKeywordSelector.where(keyword: keyword).take
      selector = JSON.parse(s.selector) unless s.nil?
    end
    return {
      keyword: keyword,
      r_keywords: r_ks,
      r_cats: r_cats,
      selector: selector
    }
  end

  def swan_fav_add
    begin
      fav = SwanFav.where(swan_id: params[:swan_id], item_id: params[:item_id].to_i).take || SwanFav.new
      fav.swan_id = params[:swan_id]
      fav.item_id = params[:item_id].to_i
      fav.fav_price = params[:fav_price]
      fav.coupon_money = params[:fav_coupon]
      if params[:form_id]
        fav.form_id = params[:form_id]
      end
      fav.status = 1
      fav.save
      render json: {status: 1}
    rescue
      render json: {status: 0}
    end
  end

  def swan_fav_del
    begin
      fav = SwanFav.where(swan_id: params[:swan_id], item_id: params[:item_id].to_i).take
      if fav.nil?
        render json: {status: 0}
        return
      end
      fav.status = 0
      fav.save
      render json: {status: 1}
    rescue
      render json: {status: 0}
    end
  end

  def swan_kefu_click
    begin
      if params[:swan_id].nil? || params[:item_id].nil? || params[:swan_id].empty? || params[:item_id].to_i.zero?
        render json: {status: 0}
        return
      end
      c = SwanKefuClick.new
      c.swan_id = params[:swan_id]
      c.item_id = params[:item_id].to_i
      c.kouling = params[:kouling]
      c.taobao_url = params[:taobao_url]
      c.save
      render json: {status: 1}
    rescue
      render json: {status: 0}
    end
  end

  def swan_kefu_go
    g = SwanKefuClick.where(id: params[:id]).take
    if g && g.taobao_url
      redirect_to g.taobao_url
    else
      redirect_to "http://uuu.uuhaodian.com"
    end
  end

  def swan_uu_login
    if params[:swan_id].nil? || params[:code].nil?
      render json: {status: 0}
      return
    end
    begin
      url = "https://spapi.baidu.com/oauth/jscode2sessionkey?client_id=#{$swan_uu_id}&sk=#{$swan_uu_sk}&code=#{params[:code]}"
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri)
      response = http.request(request)
      u = SwanUuUser.where(swan_id: params[:swan_id]).take || SwanUuUser.new
      u.swan_id = params[:swan_id]
      u.open_id = JSON.parse(response.body)["openid"]
      u.save
      render json: {status: 1}
    rescue
      render json: {status: 0}
    end
  end

  def xcx_kmap
    page = params[:page].nil? ? 0 : params[:page].to_i
    ks = TbKeyword.select(:keyword).order("id").offset(500 * page).limit(500).pluck(:keyword)
    render json: {status: 1, keywords: ks}
  end

  def swan_jump
    if is_robot?
      render json: []
      return
    end
    x = params[:x].nil? ? 0 : params[:x].to_i
    s = SwanJumpSetting.where(source_id: params[:s].to_i).select(:id, :to_app, :to_path, :sort, :x).order("sort desc").to_a
    if s.size.zero?
      render json: []
      return
    end
    if in_shenhe = s.select{|j| j.x == x}[0]
      render json: [in_shenhe]
    else
      render json: s
    end
  end

  def swan_in_sh
    render plain: ""
    if SwanApp.exists?(app_id: params[:app_id].to_i, x: params[:x].to_i)
      ip = SwanShenheIp.where(ip: request.remote_ip).take || SwanShenheIp.new
      ip.ip = request.remote_ip
      ip.save
    end
  end
end
