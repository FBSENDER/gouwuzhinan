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
      p "xxxx"
      p page
      tag = MmTag.where(tag: tag_name).take
      if tag.nil?
        render json: {status: 0}
        return
      end
      all_ids = tag.topic_ids.split(',')
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
end
