require "wechat/version"
require 'nokogiri'

module Wechat
  
  # class Parser
    
  #   def self.get_message xml
  #     doc = Nokogiri::XML(xml)
  #     to = doc.xpath("//ToUserName").first.content
  #     from = doc.xpath("//FromUserName").first.content
  #     created_at = Time.at(doc.xpath("//CreateTime").first.content.to_i)
  #     msg_type = doc.xpath("//MsgType").first.content
  #     content = doc.xpath("//Content").first.content

  #     {to: to, from: from, created_at: created_at, msg_type: msg_type, content: content}
  #   end

  # end

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
end
