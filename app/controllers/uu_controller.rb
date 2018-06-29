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

  def goods_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    keyword = params[:keyword]
    sort = params[:sort].nil? ? 7 : params[:sort].to_i
    render json: lanlan_search_coupon_list(keyword, sort, 0, page, 20), callback: params[:callback]
  end

  def tb_goods_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    keyword = params[:keyword]
    tb_coupon_result = get_tbk_coupon_search_json(keyword, 218532065, page)
    if tb_coupon_result && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]  && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]["tbk_coupon"] && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]["tbk_coupon"].size > 0
      data = {status: 1, results: tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]["tbk_coupon"]}
      render json: data, callback: params[:callback]
      return 
    end
    tb_result = get_tbk_search_json(keyword, page)
    if tb_result && tb_result["tbk_item_get_response"]["total_results"] > 0
      data = {status: 2, results: tb_result["tbk_item_get_response"]["results"]["n_tbk_item"]}
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
    render json: lanlan_type_coupon_list(4, 1, page, 20), callback: params[:callback]
  end

  def temai_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    render json: lanlan_type_coupon_list(1, 1, page, 20), callback: params[:callback]
  end

  def sale_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    render json: lanlan_type_coupon_list(2, 1, page, 20), callback: params[:callback]
  end

  def brand_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    render json: lanlan_type_coupon_list(3, 1, page, 20), callback: params[:callback]
  end

  def user_login
    begin
      url = "https://api.weixin.qq.com/sns/jscode2session?appid=wx3abfca2f798f0e6c&secret=dab3feb141a0f8635cd45795d00e684c&js_code=#{params[:code]}&grant_type=authorization_code"
      result = Net::HTTP.get(URI(URI.encode(url)))
      data = JSON.parse(result)
      user = UuUser.where(open_id: data["openid"]).take || UuUser.new
      user.open_id = data["openid"]
      user.session_key = data["session_key"]
      user.save
      render json: result
    rescue
      render json: {status: -1}
    end
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
    puts tmp_str
    key = Digest::SHA1.hexdigest(tmp_str)
    puts key
    puts params[:signature]
    if key == params[:signature]
      render plain: params[:echostr]
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

  def apply_high_commission(product_id, pid)
    url = "https://www.heimataoke.com/api-zhuanlian?appkey=#{$heima_appkey}&appsecret=#{$heima_appsecret}&sid=28&pid=#{pid}&num_iid=#{product_id}"
    JSON.parse(Net::HTTP.get(URI(url)))
  end

  def buy
    begin
      url = "https://detail.taobao.com/item.htm?id=#{params[:id]}"
      result = apply_high_commission(params[:id], $pid)
      url = result["coupon_click_url"] unless result["coupon_click_url"].nil?
      if params[:xcx]
        render plain: url
        return
      else
        redirect_to url, status: 302
      end
      click = ProductClick.new
      click.product_id = params[:id].to_i
      click.activity_id = params[:activity_id]
      click.commission_rate = result["max_commission_rate"].nil? ? 0 : result["max_commission_rate"].to_f
      click.status =  click.commission_rate == 0 ? 0 : 1
      click.referer = 'weixin'
      click.save
    rescue
    end
  end

  def pcbuy
    begin
      url = "https://detail.taobao.com/item.htm?id=#{params[:id]}"
      result = apply_high_commission(params[:id], $pc_pid)
      url = result["coupon_click_url"] unless result["coupon_click_url"].nil?
      url += "&activityId=#{params[:activity_id]}" if params[:activity_id]
      redirect_to url, status: 302
      click = ProductClick.new
      click.product_id = params[:id].to_i
      click.activity_id = params[:activity_id]
      click.commission_rate = result["max_commission_rate"].nil? ? 0 : result["max_commission_rate"].to_f
      click.status =  click.commission_rate == 0 ? 0 : 1
      click.referer = 'uu_web_pc'
      click.save
    rescue
    end
  end

  def get_tbk_search_json(keyword, page_no)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_item_get(keyword, $taobao_app_id, $taobao_app_secret, page_no,50))
  end

  def get_tbk_coupon_search_json(keyword, adzone, page_no)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_dg_item_coupon_get(keyword, adzone, $taobao_app_id, $taobao_app_secret, page_no,50))
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
    tbk = Tbkapi::Taobaoke.new
    result = JSON.parse(tbk.taobao_tbk_tpwd_create(params[:url],params[:content], $taobao_app_id, $taobao_app_secret, params[:logo], params[:user_id]))
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

end
