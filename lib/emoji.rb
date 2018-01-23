module Wechat
  class Emoji

    def self.has_emoji? text
      word_based_regex = /\/:\w*/      
      return !text.nil? && !text.match(word_based_regex).nil?
    end

  end
end
