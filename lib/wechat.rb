require 'wechat/version'
require 'nokogiri'
require 'httparty'
require 'httmultiparty'
require 'json'
require 'emoji'
require 'exception'

module Wechat
  class Client
    attr_accessor :app_id, :secret, :access_token, :access_token_expiry, :customer_token, :validate, :error
    SEND_URL = 'https://api.wechat.com/cgi-bin/message/custom/send?access_token='
    PROFILE_URL = 'https://api.wechat.com/cgi-bin/user/info?'
    UPLOAD_URL = 'http://api.wechat.com/cgi-bin/media/upload?access_token='
    FILE_URL = 'http://file.api.wechat.com/cgi-bin/media/get?access_token='
    ACCESS_TOKEN_URL = 'https://api.wechat.com/cgi-bin/token'



    #
    # Initialize a wechat client
    #
    # @param [String] app_id The id of the application
    # @param [String] secret Secret key
    # @param [String] customer_token Encryption token
    # @param [Boolean] validate Whether or not to validate the request
    # @param [String] access_token The access_token
    # @param [DateTime] access_token_expiry The expiry of the access_token
    #
    def initialize(app_id, secret, customer_token, validate=true, access_token = nil, access_token_expiry = nil)
      @app_id = app_id
      @secret = secret
      @customer_token = customer_token
      @validate = validate

      @access_token = access_token
      @access_token_expiry = access_token_expiry
      @error = nil
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
      if validate
        return digest == signature
      else
        return true
      end
    end

    # When developers try to authenticate a message
    # for the first time, the WeChat server sends a
    # POST request containing the validation params and
    # the message in the body and converts to JSON string
    #
    # @param xml_message [XML] an XML object containing the message
    # @param aes_key String
    # @param parse_emoji Boolean
    # @return [JSON] the message
    def receive_message xml_message, aes_key=nil, parse_emoji=false
      doc = Nokogiri::XML(xml_message)
      out = []
      if !aes_key.nil?
        data = doc.xpath('//Encrypt').text.strip
        key=aes_key + '='
        decipher = OpenSSL::Cipher::AES256.new :CBC
        decipher.decrypt
        decipher.key = key.unpack('m')[0]
        plain_text = process_text(decipher.update(data.unpack('m')[0]), parse_emoji)
        doc = Nokogiri::XML(plain_text[/<xml[\s\S]*?<\/xml>/])
      end
      doc.xpath('//xml').each do |node|
        hash = {}
        node.xpath('ToUserName | FromUserName | CreateTime | MsgType | Event | EventKey | Content | PicUrl | MediaId | MsgId | Format | Recognition | Location_X | Location_Y | Scale | Encrypt').each do |child|
          hash["#{child.name}"] = process_text(child.text.strip, parse_emoji)
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
      get_access_token
      request = case msg_type
        when 'text'
          { touser: to, msgtype: msg_type, text: { content: content }}.to_json
        when 'image'
          { touser: to, msgtype: msg_type, image: { media_id: content }}.to_json
        end
      send request
    end
    # Sends an image message
    #
    # @param to [String] The recipient of the message
    # @param file [File] The file to be sent
    # @return [String] the media id
    def send_image to, file
      get_access_token

      # response = HTTParty.post(url, body: request, :debug_output => $stdout)
      media_id = upload_image(file)

      return send_message to, 'image', media_id
    end

    # Get the url for an attachment
    #
    # @param media_id [String] the id of the media file
    #
    # @return [String] the url
    def get_media_url media_id
      get_access_token
      return "#{FILE_URL}#{access_token}&media_id=#{media_id}"
    end

    def upload_image file
      media_id = nil
      begin
        response = HTTMultiParty.post("#{UPLOAD_URL}#{@access_token}", body: { type: 'Image', media: file }, debug_output: $stdout, timeout: 300)
        if response.code == 200
          result = JSON.parse(response.body)

          if WeChatException.has_error?(result)
            raise WeChatException.get_error(result, @app_id)
          else
            media_id = result['media_id']
          end
        end
      rescue Net::ReadTimeout => tme
        raise Wechat::TimeoutException.new("Timeout while accessing #{UPLOAD_URL} - #{@app_id}")
      end
      return media_id
    end

    def send_multiple_rich_messages to, messages
      get_access_token
      articles = []
      messages.each do |message|
        articles << { title: message[:title], description: message[:description], picurl: message[:picurl] }
      end
      request = { touser: "#{to}", msgtype: "news", news: { articles: articles }}.to_json
      send request
    end

    # Sends a rich media message
    #
    # @param to [String] The recipient of the message
    # @param title [String] The title of the message
    # @param description [String] Description
    # @param pic_url [String] The url of the multimedia
    #
    # @return [Boolean] if message was sent successfully
    def send_rich_media_message to, title, description, pic_url
      send_multiple_rich_messages to, [{ title: title, description: description, picurl: pic_url }]
    end


    # Get's the WeChat user's profile
    #
    # {
    #   "subscribe": 1,
    #   "openid": "o6_bmjrPTlm6_2sgVt7hMZOPfL2M",
    #   "nickname": "Band",
    #   "sex": 1,
    #   "language": "zh_CN",
    #   "city": "Guangzhou",
    #   "province": "Guangdong",
    #   "country": "China",
    #   "headimgurl":    "http://wx.qlogo.cn/mmopen/g3MonUZtNHkdmzicIlibx6iaFqAc56vxLSUfpb6n5WKSYVY0ChQKkiaJSgQ1dZuTOgvLLrhJbERQQ4eMsv84eavHiaiceqxibJxCfHe/0",
    #   "subscribe_time": 1382694957
    # }
    #
    # @param to [OpenId] Unique user's ID
    # @return [String] user's name
    def get_profile user_id, lang="en_US"
      get_access_token
      url = "#{PROFILE_URL}access_token=#{access_token}&openid=#{user_id}&lang=#{lang}"

      begin
        response = HTTParty.get(url, :debug_output => $stdout)
        if response && response.code == 200
          result = JSON.parse(response.body)
          if WeChatException.has_error?(result)
            raise WeChatException.get_error(result, @app_id)
          else
            return result
          end
        else
          raise WeChatException.new('Error: Unable to retreive user profile try again later')
        end
      rescue Net::ReadTimeout => nre
        raise TimeoutException.new("Timeout accessing profile #{PROFILE_URL}")
      end
    end

    def get_access_token
      # check if token has expired or is empty
      if (@access_token_expiry.to_i < Time.now.to_i + 60) || @access_token.nil?
        # fetch new token and return it and access token expiry
        response = HTTParty.get("#{ACCESS_TOKEN_URL}?grant_type=client_credential&appid=#{@app_id}&secret=#{@secret}", :debug_output => $stdout)
        hash = JSON.parse(response.body).merge(Hash['time_stamp',Time.now.to_i])
        if !hash['errcode'].nil?
          @error = hash['errmsg']
          raise AccessTokenException.new("Error getting access token for #{@app_id} - #{@error}")
        else
          @access_token = hash["access_token"]
          @access_token_expiry = Time.at(hash["expires_in"].to_i + hash["time_stamp"].to_i)
        end
      end
    end

    private
      def send request
        url = "#{SEND_URL}#{@access_token}"
        begin
          response = HTTParty.post(url, body: request, :debug_output => $stdout)
          if response.code == 200
            result = JSON.parse(response.body)
            if WeChatException.has_error?(result)
              raise WeChatException.get_error(result, @app_id)
            else
              return result['errmsg'] == 'ok'
            end
          else
            # either a 400 or other kind of exception
            raise WeChatException.new("Unexpected error #{response.code} when trying to send - #{@app_id}")
          end
        rescue Net::ReadTimeout => nre
          raise TimeoutException.new("Timeout exception while sending message - #{@app_id}")
        end
      end

      def process_text raw, handle_emoji
        if handle_emoji
          Wechat::Emoji.replace_with_unicode raw
        end
        raw
      end
  end

  class AccessTokenException < Exception
    def initialize(msg="Error with getting the access token")
      super
    end
  end
end
