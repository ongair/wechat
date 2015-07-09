require 'wechat/version'
require 'nokogiri'
require 'httparty'
require 'json'
require 'rack'
require 'rack/session/redis'
require 'debugger'
require 'timecop'

module Wechat
  class AccessToken
    ACCESS_TOKEN_URL = 'https://api.wechat.com/cgi-bin/token'
    attr_accessor :access_token

    def initialize(app_id, secret)
      @app_id = app_id
      @secret = secret
    end

    ##
    # An access token is a globally unique token that each official account must obtain before calling APIs.
    # Normally, an access token is valid for 7,200 seconds.
    # Getting a new access token will invalidate the previous one.
    #
    # @return [JSON] hash [access_token, expires_in:(7200)]
    #
    def access_token
      redis = Redis.new
      if redis.get(@app_id).nil?
        response = HTTParty.get("#{ACCESS_TOKEN_URL}?grant_type=client_credential&appid=#{@app_id}&secret=#{@secret}", :debug_output => $stdout)
        hash = JSON.parse(response.body).merge(Hash['time_stamp',Time.now.to_i, 'new_token_requested', false])
        redis.set @app_id, hash.to_json
        @access_token = JSON.parse(redis.get(@app_id))['access_token']
      else
        token_time_valid = (Time.now.to_i - JSON.parse(redis.get(@app_id))['time_stamp'] <= JSON.parse(redis.get(@app_id))['expires_in'] - 300)

        #if we have more than 5 minutes left on the clock.
        #return cached token and do nothing.
        if token_time_valid
          @access_token = JSON.parse(redis.get(@app_id))['access_token']
        else
          #if the access token has expired get a new one.
          if JSON.parse(redis.get(@app_id))['time_stamp'] + JSON.parse(redis.get(@app_id))['expires_in'] <= Time.now.to_i
            unless JSON.parse(redis.get(@app_id))['new_token_requested']
              get_new_access_token redis
              @access_token = JSON.parse(redis.get(@app_id))['access_token']
            else #if a new request comes in and we have to wait for the new token.
              while JSON.parse(redis.get(@app_id))['new_token_requested']  do
                puts("waiting for new token" )
              end
              @access_token = JSON.parse(redis.get(@app_id))['access_token']
            end
          else
           #if the token has less than five minutes on it....we can use the current oken and get a new one.
           @access_token = JSON.parse(redis.get(@app_id))['access_token']
           unless JSON.parse(redis.get(@app_id))['new_token_requested']
             get_new_access_token redis
           end
         end
       end
    end
    @access_token
    end

    def get_new_access_token redis
      time_stamp = JSON.parse(redis.get(@app_id))['time_stamp']
      hash = Hash['access_token',JSON.parse(redis.get(@app_id))['access_token'],'expires_in',7200, 'time_stamp', time_stamp, 'new_token_requested', true]
      redis.set @app_id, hash.to_json
      response = HTTParty.get("#{ACCESS_TOKEN_URL}?grant_type=client_credential&appid=#{@app_id}&secret=#{@secret}", :debug_output => $stdout)
      hash = JSON.parse(response.body).merge(Hash['time_stamp',Time.now.to_i, 'new_token_requested', false])
      redis.set @app_id, hash.to_json
    end
  end

  class Client
    attr_accessor :access_token, :customer_token
    SEND_URL = 'https://api.wechat.com/cgi-bin/message/custom/send?access_token='

    def initialize(app_id, secret, customer_token)
      @app_id = app_id
      @secret = secret
      @customer_token = customer_token
      @access_token = AccessToken.new(app_id, secret).access_token
    end


    ##
    # When a message is sent, it is posted to the server. Upon verifying the
    # message source we return the echostr to the wechat server and parse the message
    # which is contained within the response body for the message
    #
    # @param nonce [Integer] a random number
    # @param signature [String] the timestamp and nonce parameters
    # @param timestamp [TimeStamp] timestamp
    # @return [Boolean] the digest == signature
    ##
    def authenticate(nonce, signature, timestamp)
      array = [customer_token, timestamp, nonce].sort!
      check_str = array.join

      digest = Digest::SHA1.hexdigest check_str
      # digest == signature
      digest == signature
    end

    # When developers try to authenticate a message
    # for the first time, the WeChat server sends a
    # POST request containing the validation params and
    # the message in the body and converts t JSON string
    #
    # @param message [XML] an XML object containing the message
    # @return [JSON] the message
    def receive_message xml_message
      doc = Nokogiri::XML(xml_message)
      out = []

      doc.xpath('//xml').each do |node|
        hash = {}
        node.xpath('ToUserName | FromUserName | CreateTime | MsgType | Event | Content | PicUrl | MediaId | MsgId').each do |child|
          hash["#{child.name}"] = child.text.strip
        end
        out << hash
      end
      out.first
    end

    # Sends a message
    #
    # @param to [String] The recipient of the message
    # @param msg_type [String] The type of message. Can be text or image.
    # @param content [String] The message or media_id
    # @return [Boolean] if message was sent successfully
    def send_message to, msg_type, content
      request = case msg_type
      when 'text'
        { touser: to, msgtype: msg_type, text: { content: content }}.to_json
      when 'image'
        { touser: to, msgtype: msg_type, image: { media_id: content }}.to_json
      end
      send request
    end

    def send_multiple_rich_messages to, messages
      articles = []
      messages.each do |message|
        articles << { title: message[:title], description: message[:description], picurl: message[:picurl] }
      end
      request = { touser: "#{to}", msgtype: "news", news: { articles: articles }}.to_json
      send request
    end

    def send_rich_media_message to, title, description, pic_url

      # request = { touser: "#{to}", msgtype: "news", news: { articles: [{ title: "#{title}", description: "#{description}", picurl: "picurl" }] }}.to_json
      # send request
      send_multiple_rich_messages to, [{ title: title, description: description, picurl: pic_url }]
    end

    private
      def send request
        url = "#{SEND_URL}#{@access_token}"
        response = HTTParty.post(url, body: request, :debug_output => $stdout)
        JSON.parse(response.body)["errmsg"] == "ok"
      end
  end

  # class Notification
 #    TEXT_NOTIFICATION = 'text'
 #    EVENT = 'event'
 #    CLICK = 'CLICK'
 #
 #    attr_accessor :notification_type, :content, :from, :created_at, :event_key, :event
 #
 #    def initialize(xml_string)
 #      parse(xml_string)
 #    end
 #
 #    def parse(xml)
 #      doc = Nokogiri::XML(xml)
 #      to = doc.xpath("//ToUserName").first.content
 #      @from = doc.xpath("//FromUserName").first.content
 #      @created_at = Time.at(doc.xpath("//CreateTime").first.content.to_i)
 #      @notification_type = doc.xpath("//MsgType").first.content
 #      @content = doc.xpath("//Content").first.content if !doc.xpath("//Content").first.nil?
 #      @event_key = doc.xpath("//EventKey").first.content if !doc.xpath("//EventKey").first.nil?
 #      @event = doc.xpath("//Event").first.content if !doc.xpath("//Event").first.nil?
 #    end
 #
 #    def is_message?
 #      @notification_type == TEXT_NOTIFICATION
 #    end
 #
 #    def is_event?
 #      @notification_type == EVENT
 #    end
 #
 #    def is_click?
 #      @event == CLICK
 #    end
 #  end
end
