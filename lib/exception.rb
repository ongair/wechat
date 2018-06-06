module Wechat
  class WeChatException < Exception

    def self.has_error? hash
      hash.has_key?('errcode')
    end

    def self.get_error hash
      code = hash['errcode']
      case code
      when 40003
        error = InvalidOpenIdException.new
      when 48001, 50001
        error = InsufficientPermissionsException.new
      end
      error
    end

  end

  class MediaUploadException < WeChatException
  end

  class InsufficientPermissionsException < WeChatException
  end

  class InvalidOpenIdException < WeChatException
  end


end
