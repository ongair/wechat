require 'wechat/version'
require 'nokogiri'
require 'httparty'
require 'redis'
require 'json'

module Wechat
  
  class Notification
    TEXT_NOTIFICATION = 'text'

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
      @content = doc.xpath("//Content").first.content
    end

    def is_message?
      @notification_type == TEXT_NOTIFICATION
    end
  end

  class Client

    TOKEN_URL = 'https://api.weixin.qq.com/cgi-bin/token'
    SEND_URL = 'https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token='

    def initialize(app_id, secret, access_token=nil)
      @access_token = access_token
      @redis = Redis.new

      if access_token.nil?
        get_token(app_id, secret)
      end
    end

    def send_message to, text
      url = "#{SEND_URL}#{@access_token}"
      
      request = { touser: "#{to}", msgtype: "text", text: { content: "#{text}" }}.to_json            
      response = HTTParty.post(url, body: request, :debug_output => $stdout)

      JSON.parse(response.body)["errmsg"] == "ok"
    end

    def has_token?
      !@access_token.nil? || !@redis.get('access_token').nil?
    end

    private

    def get_token app_id, secret
      response = HTTParty.get("#{TOKEN_URL}?grant_type=client_credential&appid=#{app_id}&secret=#{secret}", :debug_output => $stdout)
      @access_token = response["access_token"]
      expiry = response["expires_in"]      

      
      @redis.set 'access_token', @access_token
      @redis.expire 'access_token', expiry.to_i
    end

    
  end
end
