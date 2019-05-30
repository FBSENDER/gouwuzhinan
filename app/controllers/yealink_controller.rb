require 'yealink'
class YealinkController < ApplicationController
  def users
    begin
      u = YealinkUser.new
      u.name = params[:name].strip
      u.company = params[:company].strip
      u.phone = params[:phone].strip
      u.detail = params[:detail].strip
      u.save
      render json: {status: 1}
    rescue
      render json: {status: 0}
    end
  end
end
