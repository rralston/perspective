require 'net/http'
class StaticPagesController < ApplicationController
  def index
    #@categories = all_categories
  end
  
  def all_categories
    uri = URI.parse("http://api.feedzilla.com/v1/categories.json")
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
