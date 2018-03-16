require 'net/http'
require 'lanlan_api' 
class UuController < ApplicationController
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
end
