require 'net/http'
require 'lanlan_api' 
require 'fahuo'
class FahuoController < ApplicationController
  skip_before_action :verify_authenticity_token
  def shop_list
    page = params[:page].nil? ? 0 : params[:page].to_i
    if page > 20 || page < 0
      render json: {status: 0}
      return
    end
    data = Fahuo.select(:id, :title, :place, :score, :shop_type).order("id desc")
    render json: {status: 1, data: data}
  end

  def shop_reviews
    if params[:shop_id].nil?
      render json: {status: 0}
      return
    end
    shop = Fahuo.where(id: params[:shop_id].to_i).take
    if shop.nil?
      render json: {status: 0}
      return
    end
    reviews = []
    FahuoShopReview.connection.execute("select u.id,u.nickName,u.avatarUrl,sr.item_id,sr.item_title,sr.item_pic,lat,lng,msg,sr.created_at
from fahuo_shop_reviews sr
join fahuo_swan_users u on sr.user_id = u.id
where sr.shop_id = #{shop.id} order by sr.id").to_a.each do |row|
      reviews << {
        user_id: row[0],
        nickName: row[1],
        avatarUrl: row[2],
        item_id: row[3],
        item_title: row[4],
        item_pic: row[5],
        lat: row[6],
        lng: row[7],
        msg: row[8],
        time: row[9].to_s[0,10]
      }
    end
    render json: {status: 1, shop: shop, reviews: reviews}
  end

  def review_list
    page = params[:page].nil? ? 0 : params[:page].to_i
    if page > 20 || page < 0
      render json: {status: 0}
      return
    end
    reviews = []
    FahuoShopReview.connection.execute("select d.user_id,d.nickName,d.avatarUrl,tu.status
from wxgroup_task_users tu
join wxgroup_user_details d on tu.user_id = d.user_id
where tu.task_id = #{task.id} order by tu.status").to_a.each do |row|
      reviews << {
        user_id: row[0],
        nickName: row[1],
        avatarUrl: row[2],
        status: row[3]
      }
    end
    render json: {status: 1, data: reviews}
  end

  def new_shop
    begin
      shop = Fahuo.new
      shop.save
      render json: {status: 1, shop: shop}
    rescue
      render json: {status: 0}
    end
  end

  def new_review
    begin
      shop = Fahuo.where(seller_id: params[:seller_id].to_i).take || Fahuo.new
      shop.seller_id = params[:seller_id].to_i
      shop.title = params[:shop_title]
      shop.nick = params[:nick]
      shop.place = params[:provcity]
      shop.score = params[:shop_dsr].to_i
      shop.shop_type = params[:user_type].to_i
      shop.save
      review = FahuoShopReview.new
      review.shop_id = shop.id
      review.item_id = params[:item_id].to_i
      review.item_title = params[:item_title]
      review.item_pic = params[:item_pic]
      review.msg = params[:msg]
      review.user_id = params[:user_id].to_i
      review.lat = params[:lat] || 0
      review.lng = params[:lng] || 0
      review.save
      render json: {status: 1, shop_id: shop.id}
    rescue
      render json: {status: 0}
    end
  end

  def remove_review
    if params[:review_id].nil? || params[:user_id].nil?
      render json: {status: 0}
      return
    end
  end

  def swan_user_login
    if params[:code].nil?
      render json: {status: 0}
      return
    end
    begin
      url = "https://spapi.baidu.com/oauth/jscode2sessionkey?client_id=#{$swan_fahuo_id}&sk=#{$swan_fahuo_sk}&code=#{params[:code]}"
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri)
      response = http.request(request)
      open_id = JSON.parse(response.body)["openid"]
      u = FahuoSwanUser.where(open_id: open_id).take 
      if u
        render json: {status: 1, user: u}
      else
        u = FahuoSwanUser.new
        u.open_id = open_id
        u.nickName = ''
        u.gender = 0
        u.avatarUrl = ''
        u.save
        render json: {status: 1, user: u}
      end
    rescue
      render json: {status: 0}
    end
  end

  def swan_user_detail
    if params[:id].nil? || params[:open_id].nil? || params[:nickName].nil? || params[:avatarUrl].nil? || params[:gender].nil?
      render json: {status: 0}
      return
    end
    begin
      user = FahuoSwanUser.where(id: params[:id].to_i, open_id: params[:open_id]).take
      if user.nil?
        render json: {status: 0}
        return
      end
      user.nickName = params[:nickName]
      user.avatarUrl = params[:avatarUrl]
      user.gender = params[:gender]
      user.save
      render json: {status: 1}
    rescue
      render json: {status: 0}
    end

  end

end
