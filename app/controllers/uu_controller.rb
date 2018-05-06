require 'net/http'
require 'lanlan_api' 
require 'uuhaodian'
class UuController < ApplicationController
  skip_before_action :verify_authenticity_token
  def home_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    cid = params[:cid].nil? ? 0 : params[:cid].to_i
    sort = params[:sort].nil? ? 7 : params[:sort].to_i
    render json: lanlan_coupon_list(cid, sort, page, 20)
  end

  def product
    render json: lanlan_coupon_detail(params[:item_id])
  end

  def goods_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    keyword = params[:keyword]
    sort = params[:sort].nil? ? 7 : params[:sort].to_i
    render json: lanlan_search_coupon_list(keyword, sort, 0, page, 20)
  end

  def tb_goods_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    keyword = params[:keyword]
    tb_coupon_result = get_tbk_coupon_search_json(keyword, 218532065, page)
    if tb_coupon_result && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]  && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]["tbk_coupon"] && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]["tbk_coupon"].size > 0
      data = {status: 1, results: tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]["tbk_coupon"]}
      render json: data
      return 
    end
    tb_result = get_tbk_search_json(keyword, page)
    if tb_result && tb_result["tbk_item_get_response"]["total_results"] > 0
      data = {status: 2, results: tb_result["tbk_item_get_response"]["results"]["n_tbk_item"]}
      render json: data
      return
    end
    render json: {status: 0}
  end

  def category_list
    render json: lanlan_category_list
  end

  def jiukuaijiu_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    render json: lanlan_type_coupon_list(4, 1, page, 20)
  end

  def temai_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    render json: lanlan_type_coupon_list(1, 1, page, 20)
  end

  def sale_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    render json: lanlan_type_coupon_list(2, 1, page, 20)
  end

  def brand_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    render json: lanlan_type_coupon_list(3, 1, page, 20)
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
      redirect_to url, status: 302
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

  def get_tbk_search_json(keyword, page_no)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_item_get(keyword, $taobao_app_id, $taobao_app_secret, page_no,50))
  end

  def get_tbk_coupon_search_json(keyword, adzone, page_no)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_dg_item_coupon_get(keyword, adzone, $taobao_app_id, $taobao_app_secret, page_no,50))
  end

end
