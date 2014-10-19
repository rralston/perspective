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
    @articles = list["articles"].first(7)
  end

  def analysis_old
    if params[:src].blank?
     redirect_to :back
    else
     @src = params[:src].gsub(' ', '+')
     puts @src.inspect
     #results = AlchemyAPI::KeywordExtraction.new.search(url: 'http://www.washingtonpost.com/blogs/capital-weather-gang/wp/2013/08/14/d-c-area-forecast-ultra-nice-weather-dominates-next-few-days/')
     @results = AlchemyAPI::SentimentAnalysis.new.search(url: @src)
     puts @results.inspect

     hong_kong_uri = URI.parse("http://access.alchemyapi.com/calls/url/URLGetTargetedSentiment?apikey=00830c9935552ca29f2f4e95dfdce353fba20d4f&target=HONG+KONG&url="+ params[:src].gsub(' ', '+') +"")
     china_uri = URI.parse("http://access.alchemyapi.com/calls/url/URLGetTargetedSentiment?apikey=00830c9935552ca29f2f4e95dfdce353fba20d4f&target=China&url="+ params[:src].gsub(' ', '+') +"")
    puts hong_kong_uri
    hkres = Net::HTTP.get_response(hong_kong_uri)
    cres = Net::HTTP.get_response(china_uri)
    Rails.logger.info "Response #{hkres.inspect}....#{cres.inspect}"


     title = AlchemyAPI::TitleExtraction.new.search(url: @src)
     @title = title.try(:split, " | ").try(:last)
    end
  end

  def analysis
    if params[:src].blank?
      redirect_to :back
    else
      @src = params[:src].gsub(' ', '+')
      @results = AlchemyAPI::SentimentAnalysis.new.search(url: @src)

      @base_uri = "http://access.alchemyapi.com/calls/url/URLGetTargetedSentiment"
      @api_key = "00830c9935552ca29f2f4e95dfdce353fba20d4f"
      @article_url = params[:src].gsub(" ", "%20")

      china_url = @base_uri + "?apikey=" + @api_key + "&target=China&url=" + @article_url
      china_response = HTTParty.get(china_url)
      @china_sentiment, @china_score = get_sentiment_and_score(china_response)

      hk_url = @base_uri + "?apikey=" + @api_key + "&target=hong%20kong&url=" + @article_url
      hk_response = HTTParty.get(hk_url)
      @hk_sentiment, @hk_score = get_sentiment_and_score(hk_response)

       title = AlchemyAPI::TitleExtraction.new.search(url: @src)
       @title = title.try(:split, " | ").try(:last)
    end
  end

  def get_sentiment_and_score(response)
    sentiment = ''
    score = ''
    if response.code.to_s == '200'
      doc = Nokogiri::XML.parse(response.body)
      begin
        status = doc.css('status').text
        if status == 'OK'
          sentiment = doc.css('type').text
          score = doc.css('score').text
        end
      rescue Exception => e
        Rails.logger.debug "\n #{e.inspect} \n"
      end
    end
    return sentiment, score
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
