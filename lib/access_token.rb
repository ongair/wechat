module Wechat
  class AccessToken
    ACCESS_TOKEN_URL = 'https://api.wechat.com/cgi-bin/token'
    attr_accessor :access_token

    def initialize(app_id, secret)
      @app_id = app_id
      @secret = secret
      # @redis = Redis.new

      # load_from_redis
      load_from_konexta
    end

    def is_valid?
      has_token? && !token_expired?
    end

    def token_expired?
      return @expiry.to_i < Time.now.to_i + 60
    end

    def has_token?
      return !@token.nil?
    end

    def has_error?
      return !@error.nil?
    end

    def refresh
      get_new_access_token
      load_from_konexta
      # load_from_redis
    end

    # def load_from_redis
    #   # redis = Redis.new

    #   data = @redis.get(@app_id)
    #   if (data.nil? || data.empty?)
    #     # we have nothing
    #     @token = nil
    #     @timestamp = nil
    #     @expires_in = nil
    #     @error = nil
    #   else

    #     parsed = JSON.parse(data)
    #     @token = parsed['access_token']
    #     @timestamp = parsed['time_stamp']
    #     @expires_in = parsed['expires_in']
    #     @error = parsed['errcode']

    #   end
    # end

    def load_from_konexta
      # redis = Redis.new
      # data = @redis.get(@app_id)
      @konexta_client=Konexta::Client.find_by app_id: @app_id
      if @konexta_client.nil? || @konexta_client.access_token.nil?
        # we have nothing
        @token = nil
        @expiry = 0
        @error = nil
      else
        @token = @konexta_client.access_token
        @expiry = @konexta_client.access_token_expiry

        # @error = 'error message'
      end
    end

    ##
    # An access token is a globally unique token that each official account must obtain before calling APIs.
    # Normally, an access token is valid for 7,200 seconds.
    # Getting a new access token will invalidate the previous one.
    #
    # @return [JSON] hash [access_token, expires_in:(7200)]
    #
    def access_token

      if is_valid?
        return @token
      else
        # if error
        refresh
        if has_error?
          # throw an exeption
          raise AccessTokenException.new("Error getting access token for #{@app_id}")
        else
          return @token
        end
      end      
    end

    def self.has_error? response
      return !JSON.parse(response)['errcode'].nil?
    end

    def get_new_access_token
      response = HTTParty.get("#{ACCESS_TOKEN_URL}?grant_type=client_credential&appid=#{@app_id}&secret=#{@secret}", :debug_output => $stdout)
      hash = JSON.parse(response.body).merge(Hash['time_stamp',Time.now.to_i])
      if !hash['errcode'].nil?
        @error = hash['errmsg']
      else
        @konexta_client.access_token = hash["access_token"]
        @konexta_client.access_token_expiry = Time.at(hash["expires_in"].to_i + hash["time_stamp"].to_i)
        @konexta_client.save!
      end
    end
  end
end
