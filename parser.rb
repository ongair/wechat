require 'nokogiri'
class Parser
	def self.parse xml
		# xml = "<xml><ToUserName><![CDATA[gh_48d9be569b43]]></ToUserName>\n<FromUserName><![CDATA[oas3mt92o6rg8Ua3bt7ue4M5CmA4]]></FromUserName>\n<CreateTime>1422865453</CreateTime>\n<MsgType><![CDATA[text]]></MsgType>\n<Content><![CDATA[Why?]]></Content>\n<MsgId>6111160587446976358</MsgId>\n</xml>"
		doc = Nokogiri::XML(xml)
		to = doc.xpath("//ToUserName").first.content
		from = doc.xpath("//FromUserName").first.content
		created_at = Time.at(doc.xpath("//CreateTime").first.content.to_i)
		msg_type = doc.xpath("//MsgType").first.content
		content = doc.xpath("//Content").first.content

		{to: to, from: from, created_at: created_at, msg_type: msg_type, content: content}
	end
end

# puts Parser.parse "<xml><ToUserName><![CDATA[gh_48d9be569b43]]></ToUserName>\n<FromUserName><![CDATA[oas3mt92o6rg8Ua3bt7ue4M5CmA4]]></FromUserName>\n<CreateTime>1422865453</CreateTime>\n<MsgType><![CDATA[text]]></MsgType>\n<Content><![CDATA[Why?]]></Content>\n<MsgId>6111160587446976358</MsgId>\n</xml>"