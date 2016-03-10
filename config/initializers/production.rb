class << Rails.application
  def domain
    "news.hexlet.io"
  end

  def name
    "Hexlet News"
  end
end

Rails.application.routes.default_url_options[:host] = Rails.application.domain
