module Wechat
  class WeChatException < Exception

    def self.has_error? hash
      hash.has_key?('errcode')
    end

    def self.get_error hash
      code = hash['errcode']
      # error
      case code
      when 40003
        error = InvalidOpenIdException.new
      end
      error
    end

  end

  class InvalidOpenIdException < WeChatException
  end


end
