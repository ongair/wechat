require 'wechat/version'
require 'nokogiri'
require 'httparty'
require 'json'

module Wechat
  
  class Notification
    TEXT_NOTIFICATION = 'text'
    EVENT = 'event'

    attr_accessor :notification_type, :content, :from, :created_at

    def initialize(xml_string)
      parse(xml_string)
    end

    def parse(xml)
      doc = Nokogiri::XML(xml)
      to = doc.xpath("//ToUserName").first.content
      @from = doc.xpath("//FromUserName").first.content
      @created_at = Time.at(doc.xpath("//CreateTime").first.content.to_i)
      @notification_type = doc.xpath("//MsgType").first.content
      @content = doc.xpath("//Content").first.content if !doc.xpath("//Content").first.nil?
    end

    def is_message?
      @notification_type == TEXT_NOTIFICATION
    end

    def is_event?
      @notification_type == event
    end
  end

  class Client

    TOKEN_URL = 'https://api.weixin.qq.com/cgi-bin/token'
    SEND_URL = 'https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token='
    

    def initialize(app_id, secret, access_token=nil)
      @access_token = access_token
      @app_id = app_id
      @secret = secret

      if access_token.nil?
        get_token
      end
    end

    def send_message to, text        
      request = { touser: "#{to}", msgtype: "text", text: { content: "#{text}" }}.to_json            
      send request
    end

    def send_rich_media_message to, title, description, pic_url
                  
      request = { touser: "#{to}", msgtype: "news", news: { articles: [{ title: "#{title}", description: "#{description}", picurl: "picurl" }] }}.to_json          
      send request
    end

    def get_token
      response = HTTParty.get("#{TOKEN_URL}?grant_type=client_credential&appid=#{@app_id}&secret=#{@secret}", :debug_output => $stdout)      
      json = JSON.parse(response.body)

      @access_token = json["access_token"]
      expiry = json["expires_in"]      
            
      [@access_token, expiry]
    end

    def has_token?
      !@access_token.nil?
    end

    private

    def send request
      url = "#{SEND_URL}#{@access_token}"
      response = HTTParty.post(url, body: request, :debug_output => $stdout)
      JSON.parse(response.body)["errmsg"] == "ok"
    end    
  end
end
