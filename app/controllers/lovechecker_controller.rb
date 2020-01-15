require 'lanlan_api' 
require 'lovechecker'
class LovecheckerController < ApplicationController
  skip_before_action :verify_authenticity_token
  def qq_login
    if params[:code].nil?
      render json: {status: 0}
      return
    end
    begin
      url = "https://api.q.qq.com/sns/jscode2session?appid=#{$qq_lovechecker_id}&secret=#{$qq_lovechecker_secret}&js_code=#{params[:code]}&grant_type=authorization_code"
      result = Net::HTTP.get(URI(URI.encode(url)))
      data = JSON.parse(result)
      user = LoveQqUser.where(open_id: data["openid"]).take
      if user.nil?
        render json: {status: 1, openId: data["openid"], gender: 0, userInfo: nil, has_checker: 0}
        u = LoveQqUser.new
        u.open_id = data["openid"]
        u.save
        return
      else
        info = LoveQqUserDetail.where(user_id: user.id).select(:nickName, :gender, :avatarUrl).take
        has_checker = 0
        if info
          if user.gender == 1
            has_checker =  1 if Lovechecker.where(reply_user_id: user.id, status: 1).take
          elsif user.gender == 2
            has_checker = 1 if Lovechecker.where(user_id: user.id, status: 1).take
          end
        end
        render json: {status: 1, openId: data["openid"], gender: user.gender, userInfo: info, has_checker: has_checker}
      end
    rescue
      render json: {status: 0}
    end
  end

  def set_gender
    if params[:gender].to_i != 1 && params[:gender].to_i != 2
      render json: {status: 0}
      return
    end
    user = LoveQqUser.where(open_id: params[:open_id], gender: 0).take
    if user.nil?
      render json: {status: 0}
    else
      user.gender = params[:gender]
      user.save
      render json: {status: 1}
    end
  end

  def update_user_detail
    user = LoveQqUser.where(open_id: params[:open_id]).take
    if user.nil?
      render json: {status: 0}
      return
    end
    detail = LoveQqUserDetail.where(user_id: user.id).take || LoveQqUserDetail.new
    detail.user_id = user.id
    detail.nickName = params[:name] || ''
    detail.gender = params[:gender]
    detail.language = params[:language] || ''
    detail.city = params[:city] || ''
    detail.province = params[:province] || ''
    detail.country = params[:country] || ''
    detail.avatarUrl = params[:avatarUrl] || ''
    detail.save
    render json: {status: 1}
  end

  def send_checker
    user = LoveQqUser.where(open_id: params[:open_id]).take
    if user.nil?
      render json: {status: 0}
      return
    end
    c = Lovechecker.where(uniq_id: params[:uniq_id]).take
    unless c.nil?
      render json: {status: 0}
      return
    end
    c = Lovechecker.new
    c.uniq_id = params[:uniq_id]
    c.user_id = user.id
    c.message = params[:message]
    c.reply = ''
    c.reply_status = 0
    c.reply_user_id = 0
    c.status = 1
    c.send_time = Time.now
    c.save
    lg = LovecheckerLog.new
    lg.checker_id = c.id
    lg.user_id = user.id
    lg.operation = 1
    lg.save
    render json: {status: 1}
  end

  def reply_checker
    user = LoveQqUser.where(open_id: params[:open_id]).take
    if user.nil?
      render json: {status: 0}
      return
    end
    c = Lovechecker.where(uniq_id: params[:uniq_id], reply_user_id: 0, status: 1, reply_status: 0).take
    if c.nil?
      render json: {status: 0}
      return
    end
    c.reply = params[:reply]
    c.reply_status = params[:reply_status]
    c.reply_user_id = user.id
    c.reply_time = Time.now
    c.save
    lg = LovecheckerLog.new
    lg.checker_id = c.id
    lg.user_id = user.id
    lg.operation = 2
    lg.save
    render json: {status: 1}
  end

  def delete_checker
    user = LoveQqUser.where(open_id: params[:open_id]).take
    if user.nil?
      render json: {status: 0}
      return
    end
    c = Lovechecker.where(uniq_id: params[:uniq_id], user_id: user.id).take
    if c.nil?
      render json: {status: 0}
      return
    end
    c.delete_time = Time.now
    c.status = -1
    c.save
    lg = LovecheckerLog.new
    lg.checker_id = c.id
    lg.user_id = user.id
    lg.operation = 3
    lg.save
    render json: {status: 1}
  end

  def get_checker
    user = LoveQqUser.where(open_id: params[:open_id]).take
    if user.nil?
      render json: {status: 0}
      return
    end
    results = []
    Lovechecker.connection.execute("select uniq_id,lc.user_id,d1.nickName as user_name,d1.avatarUrl as user_avatar,message,reply,reply_status,reply_user_id,d2.nickName as reply_user_name,d2.avatarUrl as reply_user_avatar,send_time,reply_time
from lovechecker_checkers lc
left join lovechecker_qq_user_details d1 on lc.user_id = d1.user_id
left join lovechecker_qq_user_details d2 on lc.reply_user_id = d2.user_id
where lc.user_id = #{user.id} and status = 1").to_a.each do |row|
      results << {
        uniq_id: row[0],
        user_id: row[1],
        user_name: row[2],
        user_avatar: row[3],
        message: row[4],
        reply: row[5],
        reply_status: row[6],
        reply_user_id: row[7],
        reply_user_name: row[8],
        reply_user_avatar: row[9],
        send_time: row[10].nil? ? '' : (row[10] + 28800).strftime("%F %T"),
        reply_time: row[11].nil? ? '' : (row[11] + 28800).strftime("%F %T")
      }
    end
    render json: {status: 1, result: results}
  end

  def get_man_checker
    user = LoveQqUser.where(open_id: params[:open_id]).take
    if user.nil?
      render json: {status: 0}
      return
    end
    results = []
    Lovechecker.connection.execute("select uniq_id,lc.user_id,d1.nickName as user_name,d1.avatarUrl as user_avatar,message,reply,reply_status,reply_user_id,d2.nickName as reply_user_name,d2.avatarUrl as reply_user_avatar,send_time,reply_time
from lovechecker_checkers lc
left join lovechecker_qq_user_details d1 on lc.user_id = d1.user_id
left join lovechecker_qq_user_details d2 on lc.reply_user_id = d2.user_id
where lc.reply_user_id = #{user.id} and status = 1").to_a.each do |row|
      results << {
        uniq_id: row[0],
        user_id: row[1],
        user_name: row[2],
        user_avatar: row[3],
        message: row[4],
        reply: row[5],
        reply_status: row[6],
        reply_user_id: row[7],
        reply_user_name: row[8],
        reply_user_avatar: row[9],
        send_time: row[10].nil? ? '' : (row[10] + 28800).strftime("%F %T"),
        reply_time: row[11].nil? ? '' : (row[11] + 28800).strftime("%F %T")
      }
    end
    render json: {status: 1, result: results}
  end

  def check_status
    user = LoveQqUser.where(open_id: params[:open_id]).take
    if user.nil?
      render json: {status: 0}
      return
    end
    unless Lovechecker.exists?(user_id: user.id, reply_user_id: params[:user_id].to_i, status: 1, reply_status: 1)
      render json: {status: 0}
      return
    end
    checkers = Lovechecker.where("reply_user_id = ? and user_id <> ? and status = 1 and reply_status in (1,2)", params[:user_id].to_i, user.id).to_a
    jujue_times = checkers.select{|c| c.reply_status == 2}.size
    jujue_users = checkers.select{|c| c.reply_status == 2}.map{|c| c.user_id}.uniq.size
    jieshou_times = checkers.select{|c| c.reply_status == 1}.size
    jieshou_users = checkers.select{|c| c.reply_status == 1}.map{|c| c.user_id}.uniq.size
    love_status = jieshou_times <= 0 ? 1 : 0
    render json: {status: 1, love_status: love_status, jieshou_times: jieshou_times, jieshou_users: jieshou_users, jujue_times: jujue_times, jujue_users: jujue_users}
  end

  def checker_need_reply
    checker = Lovechecker.where(uniq_id: params[:uniq_id], status: 1, reply_status: 0).take
    if checker.nil?
      render json: {status: 0}
      return
    end
    detail = LoveQqUserDetail.where(user_id: checker.user_id).take
    if detail.nil?
      render json: {status: 0}
      return
    end
    render json: {status: 1, user_name: detail.nickName, user_avatar: detail.avatarUrl, message: checker.message, send_time: (checker.send_time + 28800).strftime("%F %T")}
  end

end
