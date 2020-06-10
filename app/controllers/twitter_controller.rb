require 'net/http'
require 'twitter'
class TwitterController < ApplicationController
  skip_before_action :verify_authenticity_token

  def jianguo
    page = params[:page] ? params[:page].to_i : 0
    page = page <= 0 ? 0 : page
    twitters = TrumpTwitter.select(:id, :source_id, :status, :content, :device, :published_at).order("source_id desc").offset(20 * page).limit(20).to_a
    if twitters.size > 0
      t = twitters.map{|x| {
        source_id: x.source_id,
        status: x.status,
        content: x.content,
        device: x.device,
        published_at: x.published_at,
        published: (x.published_at + 8 * 3600).strftime("%H:%M · %Y年%m月%d日"),
        date: (x.published_at + 8 * 3600).strftime("%m月%d日")
      }}
      render json: {status: 1, results: t}
    else
      render json: {status: 0}
    end
  end

  def jianguo_search
    page = params[:page] ? params[:page].to_i : 0
    page = page <= 0 ? 0 : page
    keyword = params[:keyword] ? params[:keyword].strip : ""
    bt = params[:bt] ? params[:bt].strip : ""
    et = params[:et] ? params[:et].strip : ""
    if !keyword.empty? && (bt.empty? || et.empty?)
      twitters = TrumpTwitter.where("content like ?", "%#{keyword}%").select(:id, :source_id, :status, :content, :device, :published_at).order("source_id desc").offset(20 * page).limit(20).to_a
    elsif keyword.empty? && (!bt.empty? && !et.empty?)
      twitters = TrumpTwitter.where("published_at between ? and ?", bt, et).select(:id, :source_id, :status, :content, :device, :published_at).order("source_id desc").offset(20 * page).limit(20).to_a
    elsif !keyword.empty? && (!bt.empty? && !et.empty?)
      twitters = TrumpTwitter.where("published_at between ? and ? and content like ?", bt, et, "%#{keyword}%").select(:id, :source_id, :status, :content, :device, :published_at).order("source_id desc").offset(20 * page).limit(20).to_a
    else
      twitters = []
    end

    if twitters.size > 0
      t = twitters.map{|x| {
        source_id: x.source_id,
        status: x.status,
        content: x.content,
        device: x.device,
        published_at: x.published_at,
        published: (x.published_at + 8 * 3600).strftime("%H:%M · %Y年%m月%d日"),
        date: (x.published_at + 8 * 3600).strftime("%m月%d日")
      }}
      render json: {status: 1, results: t}
    else
      render json: {status: 0}
    end
  end

end
