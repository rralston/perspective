require 'net/http'
class NewsController < ApplicationController
  def index
  end
  
  def countries
    @topic = params[:commit]
  end
  
  def articles
    @country = params[:loc]
    @query = params[:q]
    list = all_articles(@country, @query)
    @articles = list["articles"]
  end
  
  def all_articles(country, query)
    # http://api.feedzilla.com/v1/categories/19/subcategories/888/articles/search.json?q=Hong+Kong+Protest
    uri = URI.parse("http://api.feedzilla.com/v1/categories/19/subcategories/"+ country +"/articles/search.json?q="+ query.gsub(' ', '+') +"")
    puts uri.to_s
    #http = Net::HTTP.new(uri.host, uri.port)
    #request = Net::HTTP.get(uri)
    #http.use_ssl = true
    #response = http.request(request)
    response = Net::HTTP.get_response(uri)
    Rails.logger.info "Response #{response.inspect}"
    result =JSON.load(response.body) 
    Rails.logger.info "RESULE #{result.inspect}" 
    result      
  end
end

#category: 19 => "world news"
# sub-cat: 888 => "china"
