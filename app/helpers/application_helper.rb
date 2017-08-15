module ApplicationHelper
  def title(page_title = "")
    content_for :title, page_title.to_s
  end
  def keywords(page_keywords = "")
    content_for :keywords, page_keywords.to_s
  end
  def head_desc(page_description = "")
    content_for :head_desc, page_description.to_s
  end
  def mobile_url(path)
    content_for :mobile_url, "#{path}"
  end
  def path(path)
    content_for :path, path
  end
  def h1(h1)
    content_for :h1, h1
  end
  def disable_turbolinks?(disable = false)
    content_for :disable_turbolinks, disable ? 'data-no-turbolink' : ''
  end
end
