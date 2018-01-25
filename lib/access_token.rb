# module Wechat
#   class AccessToken
#     ACCESS_TOKEN_URL = 'https://api.wechat.com/cgi-bin/token'
#     attr_accessor :access_token

#     def initialize(app_id, secret, access_token, access_token_expiry)
#       @app_id = app_id
#       @secret = secret
#       load_from_konexta access_token, access_token_expiry
#     end

#     def is_valid?
#       has_token?
#     end

  
#     def has_token?
#       return !@token.nil?
#     end

#     def has_error?
#       return !@error.nil?
#     end

#     # def refresh
#       get_new_access_token
#       load_from_konexta
#     end

#     def load_from_konexta token, token_expiry
#       if token.nil? || token_expiry.nil? || token_expiry == 0
#         # we have nothing
#         @token = nil
#         @expiry = 0
#         @error = nil
#       else
#         @token = token.access_token
#         @expiry = token_expiry.access_token_expiry
#       end
#     end

#     ##
#     # An access token is a globally unique token that each official account must obtain before calling APIs.
#     # Normally, an access token is valid for 7,200 seconds.
#     # Getting a new access token will invalidate the previous one.
#     #
#     # @return [JSON] hash [access_token, expires_in:(7200)]
#     #
#     def access_token

#       if is_valid?
#         return @token
#       else
#         # if error
#         refresh
#         if has_error?
#           # throw an exeption
#           raise AccessTokenException.new("Error getting access token for #{@app_id}")
#         else
#           return @token
#         end
#       end      
#     end

#     def self.has_error? response
#       return !JSON.parse(response)['errcode'].nil?
#     end

#     def get_new_access_token
#       response = HTTParty.get("#{ACCESS_TOKEN_URL}?grant_type=client_credential&appid=#{@app_id}&secret=#{@secret}", :debug_output => $stdout)
#       hash = JSON.parse(response.body).merge(Hash['time_stamp',Time.now.to_i])
#       if !hash['errcode'].nil?
#         @error = hash['errmsg']
#       else
#         @token = hash["access_token"]
#         @token_expiry = Time.at(hash["expires_in"].to_i + hash["time_stamp"].to_i)
#       end
#     end
#   end
# end
