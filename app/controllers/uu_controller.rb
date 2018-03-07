require 'net/http'
require 'lanlan_api' 
class UuController < ApplicationController
  def home_list
    page = params[:page].nil? ? 1 : params[:page].to_i
    render json: lanlan_index_coupon_list(page, 20)
  end
end
