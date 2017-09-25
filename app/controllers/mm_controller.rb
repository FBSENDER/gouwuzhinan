require 'mm'
class MmController < ApplicationController
  def topic
    begin
      id = params[:id].to_i
      topic = MmTopic.where(id: id).take
      if topic.nil?
        render json: {status: 0}
        return
      end
      render json: {status: 1, content: topic}
    rescue 
      render json: {status: 0}
    end
  end

  def tag
    begin
      tag_name = params[:tag]
      page = params[:page] ? params[:page].to_i : 0
      tag = MmTag.where(tag: tag_name).take
      if tag.nil?
        render json: {status: 0}
        return
      end
      all_ids = tag.topic_ids.split(',').reverse
      ids = all_ids[page * 20, 20].map{|id| id.to_i}
      topics = MmTopic.where(id: ids).select(:id, :title, :image_dir, :views, :likes, :published_at, :tags).to_a
      render json: {status: 1, content: topics, total: all_ids.size}
    rescue 
      render json: {status: 0}
    end
  end

  def hot_tags
    tags = %w(性感 小清新 刘飞儿 可儿 美胸 美臀 萌妹 ROSI 推女神 内衣 美腿 秀人网 尤果网 DISI 陆瓷 绮里嘉 第四印象)
    render json: {status: 1, content: tags}
  end

  def search
    begin
      pkeyword = params[:keyword]
      if(pkeyword.nil? || pkeyword.strip.empty?)
        render json: {status: 0}
        return
      end
      keyword = pkeyword.strip
      page = params[:page] ? params[:page].to_i : 0
      if(page == 0)
        save_search_keyword(keyword)
      end
      tag = MmTag.where(tag: keyword).take
      unless tag.nil?
        redirect_to "/mm/tag/#{URI.encode(keyword)}/", status: 302
        return
      end
      all_ids = MmTopic.where("title like ?", "%#{keyword}%").order("id desc").pluck(:id)
      ids = all_ids[page * 20, 20].map{|id| id.to_i}
      topics = MmTopic.where(id: ids).select(:id, :title, :image_dir, :views, :likes, :published_at, :tags).to_a
      render json: {status: 1, content: topics, total: all_ids.size}
    rescue Exception => ex
      puts ex
      render json: {status: 0}
    end
  end

  def save_search_keyword(keyword)
    k = MmSearchKeyword.new
    k.keyword = keyword
    k.save
  end
end
