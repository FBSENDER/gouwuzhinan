class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
#  def set_layout
#    "m" if request.host == 'm.bighaowu.com'
#  end

  def is_robot?
    user_agent = request.headers["HTTP_USER_AGENT"]
    user_agent.present? && user_agent =~ /(bot|spider|slurp)/i
  end

  def is_device_mobile?
    user_agent = request.headers["HTTP_USER_AGENT"]
    user_agent.present? && user_agent =~ /\b(Android|iPhone|Windows Phone|Opera Mobi|Kindle|BackBerry|PlayBook|UCWEB|Mobile)\b/i
  end
  def redirect_pc_to_mobile
    if request.host == 'pc domain' && is_device_mobile?
      redirect_to "http://mobile domain#{request.path}"
    end
  end
  def not_found
    raise ActionController::RoutingError.new('NOT FOUND')
  end
end
