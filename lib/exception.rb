module Wechat
  class WeChatException < Exception

    def self.has_error? hash
      hash.has_key?('errcode') && hash['errcode'] != 0
    end

    def self.get_error hash, app_id=nil
      code = hash['errcode']
      case code
      when 40003
        error = InvalidOpenIdException.new
      when 48001, 50001
        error = InsufficientPermissionsException.new
      when 45015
        error = InvalidSubscriptionException.new("Attempted to send message to user with expired subscription - #{app_id}")
      end
      error ||= WeChatException.new("Unexepected error for #{app_id} - #{hash['errmsg']}")
      error
    end

  end

  class MediaUploadException < WeChatException
  end

  class InsufficientPermissionsException < WeChatException
  end

  class InvalidOpenIdException < WeChatException
  end

  class TimeoutException < WeChatException
  end

  class InvalidDecryptionKeyException < WeChatException
  end

  class InvalidSubscriptionException < WeChatException
  end

end
