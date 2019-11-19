require 'content'
class ContentController < ApplicationController
  def sh_home_list
    cid = params[:cid].nil? ? 0 : params[:cid].to_i
    page = params[:page].nil? ? 0 : params[:page].to_i
    ids = []
    if cid.zero?
      ids = TbkShArticle.where(status: 1).order("score desc").order("id desc").offset(20 * page).limit(20).pluck(:article_id).uniq
    else
      ids = TbkShArticle.where(category_id: cid, status: 1).order("score desc").order("id desc").offset(20 * page).limit(20).pluck(:article_id).uniq

    end
    articles = TbkArticle.where(id: ids).select(:id, :title, :images)
    render json: articles.map{|a| {id: a.id, title: a.title, images: JSON.parse(a.images)}}
  end

  def sh_new_list
    cid = params[:cid].nil? ? 0 : params[:cid].to_i
    page = params[:page].nil? ? 0 : params[:page].to_i
    ids = []
    if cid.zero?
      ids = TbkShArticle.where(status: 1).order("id desc").offset(20 * page).limit(20).pluck(:article_id).uniq
    else
      ids = TbkShArticle.where(category_id: cid, status: 1).order("id desc").offset(20 * page).limit(20).pluck(:article_id).uniq

    end
    articles = TbkArticle.where(id: ids).select(:id, :title, :images)
    render json: articles.map{|a| {id: a.id, title: a.title, images: JSON.parse(a.images)}}
  end

  def sh_related_list
    cid = params[:cid].nil? ? 0 : params[:cid].to_i
    id = params[:id].nil? ? 0 : params[:id].to_i
    ids = TbkShArticle.where("article_id > ? and category_id = ? and status = 1", id, cid).order("id").limit(10).pluck(:article_id)
    articles = TbkArticle.where(id: ids).select(:id, :title, :images)
    render json: articles.map{|a| {id: a.id, title: a.title, images: JSON.parse(a.images)}}
  end
end
