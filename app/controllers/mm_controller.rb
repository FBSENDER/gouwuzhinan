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

  def new
    begin
      page = params[:page] ? params[:page].to_i : 0
      if(page > 20)
        render json: {status: 0}
        return
      end
      topics = MmTopic.order("id desc").offset(page * 20).limit(20).select(:id, :title, :image_dir, :views, :likes, :published_at, :tags).to_a
      render json: {status: 1, content: topics, total: 20}
    rescue Exception => ex
      puts ex
      render json: {status: 0}
    end
  end

  def hot
    begin
      page = params[:page] ? params[:page].to_i : 0
      if(page > 20)
        render json: {status: 0}
        return
      end
      topics = MmTopic.order("views desc").offset(page * 20).limit(20).select(:id, :title, :image_dir, :views, :likes, :published_at, :tags).to_a
      render json: {status: 1, content: topics, total: 20}
    rescue Exception => ex
      puts ex
      render json: {status: 0}
    end
  end

  def collect
    begin
      page = params[:page] ? params[:page].to_i : 0
      all_ids = params[:ids].nil? ? [] : params[:ids].strip.split(',')
      ids = all_ids[page * 20, 20].map{|id| id.to_i}
      topics = MmTopic.where(id: ids).select(:id, :title, :image_dir, :views, :likes, :published_at, :tags).to_a
      render json: {status: 1, content: topics, total: all_ids.size}
    rescue Exception => ex
      puts ex
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
      if ids.size.zero?
        ids = (1..1000).to_a.sample(20)
      end
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

  def app_init_config
    config = MmAppInitConfig.take
    render json: {status: 1,inreview: config.inreview, update: {update_type: config.update_type, update_url: config.update_url, update_text: config.update_text, update_version: config.update_version}, appstore_comment_text: config.appstore_comment_text, appstore_comment_button_text: config.appstore_comment_button_text, default_tag: config.default_tag, default_hot: config.default_hot}
  end

  def app_feedback
    begin
      feed = MmFeedback.new
      feed.content = params[:content]
      feed.device_id = params[:device_id]
      feed.version = params[:version]
      feed.save
      render json: {status: 1}
    rescue Exception => ex
      puts ex
      render json: {status: 0}
    end
  end
end
