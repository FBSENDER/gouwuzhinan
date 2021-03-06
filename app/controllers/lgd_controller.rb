require "json"
require "lgd_jiaowu"
class LgdController < ApplicationController
  skip_before_action :verify_authenticity_token

  def jiaowu_sync
    ju = LgdJiaowuUser.where(id: params[:id].to_i).take
    if ju.nil?
      render json: {status: 0}
      return
    end
    ju.status = 2
    ju.save
    render json: {status: 1}
  end
  def jiaowu_user
    ju = LgdJiaowuUser.where(id: params[:id].to_i).take
    if ju.nil?
      render json: {status: 0}
      return
    end
    if ju.status == 1
      render json: {status: 1, result: {jiaowu_id: ju.id, number: ju.number, jiaowu_status: ju.status, pwd_status: ju.password_status, name: ju.name, point: ju.point, keyword: ju.k}}
    elsif ju.status == 2
      render json: {status: 2, result: {jiaowu_id: ju.id, number: ju.number, jiaowu_status: ju.status, pwd_status: ju.password_status, name: ju.name, point: ju.point, keyword: ju.k}}
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
      render json: {status: 1, result: {id: user.id, last_jiaowu_number: user.last_jiaowu_number, jiaowu_status: ju.status, pwd_status: ju.password_status, name: ju.name, jiaowu_id: ju.id, point: ju.point, keyword: ju.k}}
    end
  end
  def qq_login
    user = LgdQqUser.where(open_id: params[:open_id]).take
    if user.nil?
      user = LgdQqUser.new
      user.open_id = params[:open_id]
      user.save
      render json: {status: 1, result: {id: user.id, last_jiaowu_number: 0}}
    else
      if(user.last_jiaowu_number == 0)
        render json: {status: 1, result: {id: user.id, last_jiaowu_number: 0}}
        return
      end
      ju = LgdJiaowuUser.where(number: user.last_jiaowu_number).take
      render json: {status: 1, result: {id: user.id, last_jiaowu_number: user.last_jiaowu_number, jiaowu_status: ju.status, pwd_status: ju.password_status, name: ju.name, jiaowu_id: ju.id, point: ju.point, keyword: ju.k}}
    end
  end
  def swan_login
    user = LgdSwanUser.where(open_id: params[:open_id]).take
    if user.nil?
      user = LgdSwanUser.new
      user.open_id = params[:open_id]
      user.save
      render json: {status: 1, result: {id: user.id, last_jiaowu_number: 0}}
    else
      if(user.last_jiaowu_number == 0)
        render json: {status: 1, result: {id: user.id, last_jiaowu_number: 0}}
        return
      end
      ju = LgdJiaowuUser.where(number: user.last_jiaowu_number).take
      render json: {status: 1, result: {id: user.id, last_jiaowu_number: user.last_jiaowu_number, jiaowu_status: ju.status, pwd_status: ju.password_status, name: ju.name, jiaowu_id: ju.id, point: ju.point, keyword: ju.k}}
    end
  end

  def qq_jiaowu_login
    qq_user = LgdQqUser.where(id: params[:id].to_i, open_id: params[:open_id]).take
    if qq_user.nil?
      render json: {status: 0}
      return
    end
    jiaowu_user = LgdJiaowuUser.where(number: params[:number].to_i).take
    unless jiaowu_user.nil?
      if jiaowu_user.password == params[:jiaowuword]
        qq_user.last_jiaowu_number = jiaowu_user.number
        qq_user.save
        relation = LgdQqUserRelation.where(open_id: qq_user.open_id, number: jiaowu_user.number).take || LgdQqUserRelation.new
        relation.open_id = qq_user.open_id
        relation.number = jiaowu_user.number
        relation.save
        render json: {status: 1, result: {jiaowu_id: jiaowu_user.id, number: jiaowu_user.number, name: jiaowu_user.name, jiaowu_status: jiaowu_user.status, pwd_status: jiaowu_user.password_status, point: jiaowu_user.point, keyword: jiaowu_user.k}}
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
      qq_user.last_jiaowu_number= jiaowu_user.number
      qq_user.save
      relation = LgdQqUserRelation.new
      relation.open_id = qq_user.open_id
      relation.number = jiaowu_user.number
      relation.save
    end
  end

  def swan_jiaowu_login
    swan_user = LgdSwanUser.where(id: params[:id].to_i, open_id: params[:open_id]).take
    if swan_user.nil?
      render json: {status: 0}
      return
    end
    jiaowu_user = LgdJiaowuUser.where(number: params[:number].to_i).take
    unless jiaowu_user.nil?
      if jiaowu_user.password == params[:jiaowuword]
        swan_user.last_jiaowu_number = jiaowu_user.number
        swan_user.save
        relation = LgdSwanUserRelation.where(open_id: swan_user.open_id, number: jiaowu_user.number).take || LgdSwanUserRelation.new
        relation.open_id = swan_user.open_id
        relation.number = jiaowu_user.number
        relation.save
        render json: {status: 1, result: {jiaowu_id: jiaowu_user.id, number: jiaowu_user.number, name: jiaowu_user.name, jiaowu_status: jiaowu_user.status, pwd_status: jiaowu_user.password_status, point: jiaowu_user.point, keyword: jiaowu_user.k}}
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
      swan_user.last_jiaowu_number= jiaowu_user.number
      swan_user.save
      relation = LgdSwanUserRelation.new
      relation.open_id = swan_user.open_id
      relation.number = jiaowu_user.number
      relation.save
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
        relation = LgdWxUserRelation.where(open_id: wx_user.open_id, number: jiaowu_user.number).take || LgdWxUserRelation.new
        relation.open_id = wx_user.open_id
        relation.number = jiaowu_user.number
        relation.save
        render json: {status: 1, result: {jiaowu_id: jiaowu_user.id, number: jiaowu_user.number, name: jiaowu_user.name, jiaowu_status: jiaowu_user.status, pwd_status: jiaowu_user.password_status, point: jiaowu_user.point, keyword: jiaowu_user.k}}
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
      relation = LgdWxUserRelation.new
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
  def qq_jiaowu_logout
    user = LgdQqUser.where(open_id: params[:open_id]).take
    unless user.nil?
      user.last_jiaowu_number = 0
      user.save
    end
    render json: {status: 1}
  end
  def swan_jiaowu_logout
    user = LgdSwanUser.where(open_id: params[:open_id]).take
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

  def jiaowu_docs
    docs = LgdDoc.select(:id,:title,:cate,:size,:updated_at).to_a
    render json: docs
  end

  def jiaowu_doc
    doc = LgdDoc.where(id: params[:id].to_i).select(:id, :file_id, :title, :cate, :size, :desc, :updated_at).take
    if doc.nil?
      render json: {status: 0}
    else
      render json: {status: 1, doc: doc}
    end
  end

  def jiaowu_notices
    notices = LgdNotice.where(status: 1).select(:id,:title,:updated_at).order("id desc").to_a
    render json: notices
  end

  def jiaowu_notice
    notice = LgdNotice.where(id: params[:id].to_i, status: 1).select(:id, :file_ids, :title, :source_url, :updated_at).take
    if notice.nil?
      render json: {status: 0}
    else
      render json: {status: 1, notice: notice}
    end
  end

  def qq_open_id 
    if params[:code].nil?
      render json: {status: 0}
      return
    end
    begin
      url = "https://api.q.qq.com/sns/jscode2session?appid=#{$qq_lgd_id}&secret=#{$qq_lgd_secret}&js_code=#{params[:code]}&grant_type=authorization_code"
      result = Net::HTTP.get(URI(URI.encode(url)))
      data = JSON.parse(result)
      render json: {status: 1, open_id: data["openid"]}
    rescue
      render json: {status: 0}
    end
  end
end
