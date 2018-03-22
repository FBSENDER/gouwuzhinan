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
        detail = JSON.parse(lanlan_coupon_detail(item_id)
        token = UuToken.take.token
        url = "https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{token}"
        Net::HTTP.post_form(URI(url), "touser" => params[:FromUserName], "msgtype" => "link", "link" => {"title" => "#{detail["result"]["couponMoney"].to_i}元优惠券", "description" => detail["result"]["shortTitle"], "url" => "http://wap.uuhaodian.com/saber/detail?itemId=#{item_id}&pid=mm_32854514_34792441_314020343&forCms=1&super=1", "thumb_url" => detail["result"]["coverImage"]})
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
end
