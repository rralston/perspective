module NewsHelper

 def sentiment_analysis(src)
   if src.blank?
     ""
   else
     src = src.gsub(' ', '+')
     puts src.inspect
     result = AlchemyAPI::SentimentAnalysis.new.search(url: src)
     puts result.inspect  
     result #['type']
   end
 end

end
