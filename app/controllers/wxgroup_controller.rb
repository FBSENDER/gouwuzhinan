require 'net/http'
require 'lanlan_api' 
require 'wxgroup'
class WxgroupController < ApplicationController
  skip_before_action :verify_authenticity_token
  def user_login
    if params[:code].nil?
      render json: {status: 0}
      return
    end
    begin
      url = "https://api.weixin.qq.com/sns/jscode2session?appid=#{$wxgroup_id}&secret=#{$wxgroup_secret}&js_code=#{params[:code]}&grant_type=authorization_code"
      result = Net::HTTP.get(URI(URI.encode(url)))
      data = JSON.parse(result)
      user = WxgroupUser.where(open_id: data["openid"]).take
      if user.nil?
        u = WxgroupUser.new
        u.open_id = data["openid"]
        u.save
        render json: {status: 1, openId: data["openid"], userId: u.id, userInfo: nil}
        return
      else
        info = WxgroupUserDetail.where(user_id: user.id).select(:user_id, :nickName, :avatarUrl).take
        render json: {status: 1, openId: data["openid"], userId: user.id, userInfo: info}
      end
    rescue
      render json: {status: 0}
    end
  end

  def update_user_detail
    user = WxgroupUser.where(open_id: params[:open_id]).take
    if user.nil?
      render json: {status: 0}
      return
    end
    detail = WxgroupUserDetail.where(user_id: user.id).take || WxgroupUserDetail.new
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

  def add_group
    begin
      if params[:group_id].nil? || params[:group_id].empty? || params[:user_id].nil? || params[:user_id].to_i.zero?
        render json: {status: 0}
        return
      end
      group = Wxgroup.where(group_id: params[:group_id]).take
      if group
        if group.owner_id == params[:user_id].to_i
          group.group_name = params[:group_name]
          group.save
          render json: {status: 1}
          return
        else
          render json: {status: 0}
          return
        end
      else
        group = Wxgroup.new
        group.group_id = params[:group_id]
        group.group_name = params[:group_name]
        group.owner_id = params[:user_id].to_i
        group.save
        render json: {status: 1}
      end
    rescue
      render json: {status: 0}
    end
  end

  def group_register
    begin
      if params[:user_id].nil? || params[:open_id].nil? || params[:group_id].nil?
        render json: {status: 0}
        return
      end
      user = WxgroupUser.where(id: params[:user_id].to_i, open_id: params[:open_id]).take
      if user.nil?
        render json: {status: 0}
        return
      end
      r = WxgroupRegister.where(user_id: params[:user_id].to_i, group_id: params[:group_id]).take || WxgroupRegister.new
      r.user_id = params[:user_id].to_i
      r.open_id = params[:open_id]
      r.group_id = params[:group_id]
      r.status = 1
      r.save
      render json: {status: 1}
    rescue
      render json: {status: 0}
    end
  end

  def group_register_remove
    begin
      if params[:user_id].nil? || params[:group_id].nil?
        render json: {status: 0}
        return
      end
      group = Wxgroup.where(id: params[:group_id].to_i).take
      if group.nil?
        render json: {status: 0}
        return
      end
      r = WxgroupRegister.where(user_id: params[:user_id].to_i, group_id: group.group_id).take
      if r.nil?
        render json: {status: 0}
        return
      end
      r.status = -1
      r.save
      render json: {status: 1}
    rescue
      render json: {status: 0}
    end
  end

  def group_list
    if params[:user_id].nil?
      render json: {status: 0}
      return
    end
    groups = Wxgroup.where(owner_id: params[:user_id].to_i).order(:id).select(:id, :group_name).to_a
    render json: {status: 1, data: groups}
  end

  def group_users
    group = Wxgroup.where(id: params[:id].to_i).take
    if group.nil?
      render json: {status: 0}
      return
    end
    user_ids = WxgroupRegister.where(group_id: group.group_id, status: 1).order(:created_at).pluck(:user_id)
    users = WxgroupUserDetail.where(user_id: user_ids).select(:user_id, :nickName, :avatarUrl, :created_at)
    render json: {status: 1, data: users, group_name: group.group_name}
  end

  def add_task
    begin
      if params[:group_id].nil? || params[:ad_views].nil? || params[:page_views].nil? || params[:page_share].nil? || params[:haibao_share].nil?
        render json: {status: 0}
        return
      end
      task = WxgroupTask.new
      task.group_id = params[:group_id].to_i
      task.page_views = params[:page_views].to_i
      task.ad_views = params[:ad_views].to_i
      task.page_share = params[:page_share].to_i
      task.haibao_share = params[:haibao_share].to_i
      task.has_bang = 1 if params[:bang] && params[:bang].to_i > 0
      task.status = 0
      task.save
      render json: {status: 1}
    rescue
      render json: {status: 0}
    end
  end

  def end_task
    begin
      if params[:task_id].nil?
        render json: {status: 0}
        return
      end
      task = WxgroupTask.where(id: params[:task_id].to_i).take
      if task.nil?
        render json: {status: 0}
        return
      end
      task.status = 1
      task.save
      render json: {status: 1}
    rescue
      render json: {status: 0}
    end
  end

  def task_list
    if params[:group_id].nil?
      render json: {status: 0}
      return
    end
    tasks = WxgroupTask.where(group_id: params[:group_id].to_i).order("id desc").select(:id, :page_views, :ad_views, :status, :created_at, :page_share, :haibao_share)
    render json: {status: 1, data: tasks}
  end

  def task_users
    if params[:task_id].nil?
      render json: {status: 0}
      return
    end
    task = WxgroupTask.where(id: params[:task_id].to_i).select(:id, :status, :page_views, :ad_views, :money).take
    if task.nil?
      render json: {status: 0}
      return
    end
    users = []
    WxgroupTaskUser.connection.execute("select d.user_id,d.nickName,d.avatarUrl,tu.status, tu.uv 
from wxgroup_task_users tu
join wxgroup_user_details d on tu.user_id = d.user_id
where tu.task_id = #{task.id} order by tu.status desc,tu.uv desc").to_a.each do |row|
      users << {
        user_id: row[0],
        nickName: row[1],
        avatarUrl: row[2],
        status: row[3],
        uv: row[4]
      }
    end
    sum = users.size
    sum_done = users.count{|u| u[:status] == 1}
    render json: {status: 1, task: task, users: users, sum: sum, sum_done: sum_done}
  end

  def task_detail
    if params[:task_id].nil?
      render json: {status: 0}
      return
    end
    task = WxgroupTask.where(id: params[:task_id].to_i).take
    if task.nil?
      render json: {status: 0}
      return
    end
    group = Wxgroup.where(id: task.group_id).take
    if group.nil?
      render json: {status: 0}
      return
    end
    render json: {status: 1, task: task, group: group}
  end

  def task_refresh_money
    if params[:task_id].nil?
      render json: {status: 0}
      return
    end
    task = WxgroupTask.where(id: params[:task_id].to_i).take
    if task.nil?
      render json: {status: 0}
      return
    end
    # do refresh
    done_users = WxgroupTaskUser.where(task_id: params[:task_id].to_i, status: 1)
    if done_users.size < 5
      task.money = 5
    elsif done_users.size < 20
      task.money = done_users.size * 0.5
    elsif done_users.size < 50
      task.money = done_users.size * 0.4
    else
      task.money = 25
    end
    task.save
    render json: {status: 1, money: task.money}
  end

  def task_refresh_bang
    if params[:task_id].nil?
      render json: {status: 0}
      return
    end
    logs = WxgroupShareLog.where(task_id: params[:task_id].to_i).select(:user_id, :visit_id).to_a
    logs.map{|lg| lg.user_id}.uniq.each do |user_id|
      visitor = logs.select{|l| l.user_id == user_id}.map{|g| g.visit_id}
      u = WxgroupTaskUser.where(user_id: user_id, task_id: params[:task_id].to_i).take
      if u
        u.uv = visitor.uniq.size
        u.pv = visitor.size
        u.save
      end
    end
    render json: {status: 1}
  end

  def is_user_in_task
    if params[:task_id].nil? || params[:user_id].nil?
      render json: {status: 0}
      return
    end
    user = WxgroupTaskUser.where(user_id: params[:user_id].to_i, task_id: params[:task_id].to_i).take
    if user.nil?
      render json: {status: 0}
    else
      render json: {status: 1, task_status: user.status, page_share: user.page_share, haibao_share: user.haibao_share}
    end
  end

  def user_in_task
    if params[:task_id].nil? || params[:user_id].nil?
      render json: {status: 0}
      return
    end
    task = WxgroupTask.where(id: params[:task_id].to_i).take
    if task.nil?
      render json: {status: 0}
      return
    end
    group = Wxgroup.where(id: task.group_id).take
    if group.nil? 
      render json: {status: 0}
      return
    end
    register = WxgroupRegister.where(user_id: params[:user_id].to_i, group_id: group.group_id).take
    if register.nil?
      render json: {status: 0}
      return
    end
    tu = WxgroupTaskUser.where(user_id: params[:user_id].to_i, task_id: params[:task_id].to_i).take || WxgroupTaskUser.new
    tu.task_id = params[:task_id].to_i
    tu.user_id = params[:user_id].to_i
    tu.save
    render json: {status: 1}
  end

  def user_done_task
    if params[:task_id].nil? || params[:user_id].nil?
      render json: {status: 0}
      return
    end
    tu = WxgroupTaskUser.where(user_id: params[:user_id].to_i, task_id: params[:task_id].to_i).take
    if tu.nil?
      render json: {status: 0}
      return
    end
    tu.status = 1
    tu.save
    render json: {status: 1}
  end

  def user_share_task
    if params[:task_id].nil? || params[:user_id].nil? || params[:type].nil?
      render json: {status: 0}
      return
    end
    tu = WxgroupTaskUser.where(user_id: params[:user_id].to_i, task_id: params[:task_id].to_i).take
    if tu.nil?
      render json: {status: 0}
      return
    end
    if params[:type].to_i == 1
      tu.page_share += 1
      tu.save
      render json: {status: 1}
    #elsif params[:type].to_i == 2
    else
      tu.haibao_share += 1
      tu.save
      render json: {status: 1}
    end
    if params[:visit_user] && params[:visit_user].to_i > 0
      lg = WxgroupShareLog.new
      lg.task_id = params[:task_id].to_i
      lg.user_id = params[:user_id].to_i
      lg.visit_id = params[:visit_user].to_i
      lg.save
    end
  end

  def add_group_product
    if params[:group_id].nil? || params[:user_id].nil? || params[:product_id].nil?
      render json: {status: 0}
      return
    end
    gp = WxgroupPddProduct.new
    gp.group_id = params[:group_id].to_i
    gp.user_id = params[:user_id].to_i
    gp.product_id = params[:product_id].to_i
    gp.save
    render json: {status: 1}
  end
end
