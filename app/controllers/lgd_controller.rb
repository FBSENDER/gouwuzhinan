require "json"
require "lgd_jiaowu"
class LgdController < ApplicationController
  skip_before_action :verify_authenticity_token

  def jiaowu_user
    ju = LgdJiaowuUser.where(id: params[:id].to_i).take || LgdJiaowuUser.where(number: params[:id].to_i).take
    if ju.nil?
      render json: {status: 0}
      return
    end
    if ju.status == 1
      render json: {status: 1, result: {jiaowu_id: ju.id, number: ju.number, jiaowu_status: ju.status, pwd_status: ju.password_status, name: ju.name}}
    elsif ju.status == 2
      render json: {status: 2, result: {jiaowu_id: ju.id, number: ju.number, jiaowu_status: ju.status, pwd_status: ju.password_status, name: ju.name}}
    else
      render json: {status: 0}
    end
  end
  def wx_login
    user = LgdWxUser.where(open_id: params[:open_id]).take
    if user.nil?
      user = LgdWxUser.new
      user.open_id = params[:open_id]
      user.union_id = ""
      user.session_key = ""
      user.save
      render json: {status: 1, result: {id: user.id, last_jiaowu_number: 0}}
    else
      if(user.last_jiaowu_number == 0)
        render json: {status: 1, result: {id: user.id, last_jiaowu_number: 0}}
        return
      end
      ju = LgdJiaowuUser.where(number: user.last_jiaowu_number).take
      render json: {status: 1, result: {id: user.id, last_jiaowu_number: user.last_jiaowu_number, jiaowu_status: ju.status, pwd_status: ju.password_status, name: ju.name}}
    end
  end

  def jiaowu_login
    wx_user = LgdWxUser.where(id: params[:id].to_i, open_id: params[:open_id]).take
    if wx_user.nil?
      render json: {status: 0}
      return
    end
    jiaowu_user = LgdJiaowuUser.where(number: params[:number].to_i).take
    unless jiaowu_user.nil?
      if jiaowu_user.password == params[:jiaowuword]
        wx_user.last_jiaowu_number = jiaowu_user.number
        wx_user.save
        relation = LgdWjUserRelation.where(open_id: wx_user.open_id, number: jiaowu_user.number).take || LgdWjUserRelation.new
        relation.open_id = wx_user.open_id
        relation.number = jiaowu_user.number
        relation.save
        render json: {status: 1, result: {jiaowu_id: jiaowu_user.id, number: jiaowu_user.number, name: jiaowu_user.name, jiaowu_status: jiaowu_user.status, pwd_status: jiaowu_user.password_status}}
      else
        st = LgdStudent.new
        st.number = params[:number].to_i
        st.password = params[:jiaowuword]
        st.save
        render json: {status: 3} #密码不正确
      end
    else
      jiaowu_user = LgdJiaowuUser.new
      jiaowu_user.number = params[:number].to_i
      jiaowu_user.password = params[:jiaowuword]
      jiaowu_user.name = ''
      jiaowu_user.status = 2
      jiaowu_user.password_status = 1
      jiaowu_user.save
      render json: {status: 2, result:{jiaowu_id: jiaowu_user.id, number: jiaowu_user.number}} #等待同步
      wx_user.last_jiaowu_number= jiaowu_user.number
      wx_user.save
      relation = LgdWjUserRelation.new
      relation.open_id = wx_user.open_id
      relation.number = jiaowu_user.number
      relation.save
    end
  end

  def jiaowu_logout
    user = LgdWxUser.where(open_id: params[:open_id]).take
    unless user.nil?
      user.last_jiaowu_number = 0
      user.save
    end
    render json: {status: 1}
  end

  def jiaowu_scores
    score = LgdScore.where(student_id: params[:id].to_i).take
    if score.nil?
      render json: []
    else
      render json: score.scores
    end
  end

  def jiaowu_cets
    cet = LgdCet.where(student_id: params[:id].to_i).take
    if cet.nil?
      render json: []
    else
      render json: cet.cets
    end
  end

  def jiaowu_exams
    exam = LgdExam.where(student_id: params[:id].to_i).take
    if exam.nil?
      render json: []
    else
      render json: exam.exams
    end
  end

  def jiaowu_classes
    cls = LgdClass.where(student_id: params[:id].to_i).take
    if cls.nil?
      render json: []
    else
      render json: cls.classes
    end
  end
end
