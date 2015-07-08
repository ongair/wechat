# require 'spec_helper'
# require 'debugger'
#
# describe Wechat::Notification do
#   context 'Handing notifications' do
#     subject {
#       Wechat::Notification.new("<xml><ToUserName><![CDATA[gh_48d9be569b43]]></ToUserName>\n<FromUserName><![CDATA[trevor]]></FromUserName>\n<CreateTime>1422865453</CreateTime>\n<MsgType><![CDATA[text]]></MsgType>\n<Content><![CDATA[Why?]]></Content>\n<MsgId>6111160587446976358</MsgId>\n</xml>")
#     }
#
#     it { expect(subject.notification_type).to eql(Wechat::Notification::TEXT_NOTIFICATION) }
#     it { expect(subject.is_message?).to eql(true) }
#     it { expect(subject.from).to eql('trevor') }
#   end
#
#   context 'Handing subscriptions' do
#     subject {
#       Wechat::Notification.new("<xml><ToUserName><![CDATA[gh_48d9be569b43]]></ToUserName><FromUserName><![CDATA[oas3mtxFt0vPG-sC4dAnCkmRWT7M]]></FromUserName><CreateTime>1423038007</CreateTime><MsgType><![CDATA[event]]></MsgType><Event><![CDATA[subscribe]]></Event><EventKey><![CDATA[]]></EventKey></xml>")
#     }
#
#     it { expect(subject.notification_type).to eql(Wechat::Notification::EVENT)}
#   end
#
#   context 'Handle click events' do
#     subject {
#       Wechat::Notification.new("<xml><ToUserName><![CDATA[gh_ca6fe576b4e4]]></ToUserName><FromUserName><![CDATA[oTIrjt0N7gK4_mMk1UAwB7rXcNcw]]></FromUserName><CreateTime>1423048318</CreateTime><MsgType><![CDATA[event]]></MsgType><Event><![CDATA[CLICK]]></Event><EventKey><![CDATA[news]]></EventKey></xml>")
#     }
#
#     it { expect(subject.is_event?).to eql(true) }
#   end
# end
