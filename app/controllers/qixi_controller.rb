require 'net/http'
require 'lanlan_api' 
require 'uuhaodian'
class QixiController < ApplicationController
  skip_before_action :verify_authenticity_token

  def gzh_reply
    render plain: "success"
    begin
      xml = Nokogiri::XML request.body.read
      open_id = xml.xpath('//FromUserName').text
      token = UuToken.where(id: 3).take.token
      if xml.xpath('//MsgType').text == 'event'
        if xml.xpath('//Event').text == 'unsubscribe'
          unsubscribe(open_id)
        elsif xml.xpath('//Event').text == 'subscribe'
          from_id = 0
          if xml.xpath('//EventKey') != nil
            Rails.logger.info "eventKey: #{xml.xpath('EventKey').text}"
          end
          user = create_user(open_id, token, from_id)
          create_qrcode(user, token)
          get_qixi_image(user)
          upload_image(user, token)
          reply_text(token, open_id, '1')
          reply_text(token, open_id, 'www.jd.com')
          reply_image(token, open_id, user[:media_id])
        elsif xml.xpath('//Event').text == 'SCAN'
        end
      end
    rescue
      Rails.logger.fatal "ERROR: gzh_reply"
    end
  end

  def unsubscribe(open_id)
    user = QxUser.where(open_id: open_id).take
    unless user.nil?
      user.gz = 0
      user.save
    end
  end

  def create_user(open_id, access_token, from_user_id = 0, gz = 1)
    url_1 = "https://api.weixin.qq.com/sns/userinfo?access_token=#{access_token}&openid=#{open_id}"
    result_1 = Net::HTTP.get(URI(URI.encode(url_1)))
    data_1 = JSON.parse(result_1)
    user = QxUser.where(open_id: open_id).take || QxUser.new
    user.open_id = open_id
    user.union_id = ''
    user.access_token = ''
    user.session_key = ''
    user.from_user_id = from_user_id
    user.gz = gz
    user.save
    detail = QxUserDetail.where(user_id: user.id).take || QxUserDetail.new
    detail.user_id = user.id
    detail.name = data_1["nickname"]
    detail.headimgurl = data_1["headimgurl"]
    detail.sex = data_1["sex"]
    detail.language = data_1["language"]
    detail.city = data_1["city"]
    detail.province = data_1["province"]
    detail.country = data_1["country"]
    detail.save
    {id: user.id, nick: detail.name, imgurl: detail.headimgurl}
  end
  
  def create_qrcode(user, access_token)
    url = "https://api.weixin.qq.com/cgi-bin/qrcode/create?access_token=#{access_token}"
    qq =  {expire_seconds: 2592000, action_name: "QR_SCENE", action_info: {scene: {scene_id: user[:id]}}} 
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    request.body = qq.to_json
    response = http.request(request)
    data = JSON.parse(response.body)
    user[:qr_code] = "https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=#{URI.encode(data["ticket"])}"
    user
  end

  def upload_image(user, access_token)
    `curl -F media=@"public/qixi_#{user[:id]}.jpg" "https://api.weixin.qq.com/cgi-bin/media/upload?access_token=#{access_token}&type=image" > "public/qixi_#{user[:id]}.txt"`
    File.open("public/qixi_#{user[:id]}.txt", "r") do |f|
      data = f.read
      data1 = JSON.parse(data)
      user[:media_id] = data["media_id"]
    end
  end

  def check_post_message
    arr = ['uuapi', params[:timestamp], params[:nonce]].sort
    tmp_str = arr.join('')
    key = Digest::SHA1.hexdigest(tmp_str)
    puts params[:signature]
    if key == params[:signature]
      render plain: params[:echostr]
    else
      render plain: "fail"
    end
  end

  def get_qixi_image(user)
    kit = IMGKit.new("<html><head><meta charset='UTF-8'></head><body style='height:1920px;width: 800px;margin:0;padding:0;'><img src='http://www.uuhaodian.com/qixi.jpg' style='height:1920px;width:1024px;'/><img src='#{user[:qr_code]}' style='height:256px;width:256px;position:relative;top:-294px;left:698px;'/><img src='#{user[:imgurl]}' style='height:100px;width: 100px;position:relative;top:-704px;left:-192px;'/><p style='color:#532b6d;position: relative;top:-832px;left:205px;font-size:38px;font-weight: bold;'>#{user[:nick]}正在参加：<br/>七夕儿童绘本免费送活动</p></body></html>")
    kit.to_file("public/qixi_#{user[:id]}.jpg")
  end

  def reply_text(token, open_id, content)
    url = "https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{token}"
    qq = {
      "touser" => open_id,
      "msgtype" => 'text',
      "text" => {
        "content" => content
      }
    }
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    request.body = qq.to_json
    response = http.request(request)
  end
  
  def reply_image(token, open_id, media_id)
    url = "https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{token}"
    qq = {
      "touser" => open_id,
      "msgtype" => 'image',
      "image" => {
        "media_id" => media_id
      }
    }
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    request.body = qq.to_json
    response = http.request(request)
  end

end
