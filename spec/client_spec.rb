require 'spec_helper'

describe Wechat::Client do

  before do
    stub_request(:get, "#{Wechat::Client::TOKEN_URL}?appid=app_id&grant_type=client_credential&secret=secret").
      to_return(:status => 200, :body => { "access_token" => "token", "expires_in" => 7200}.to_json, :headers => {})

    stub_request(:post, "#{Wechat::Client::SEND_URL}token").
      with(:body => { touser: "12345", msgtype: "text", text: { content: "Hello world"} }.to_json ).
      to_return(:status => 200, :body => { errmsg: "ok" }.to_json, :headers => {})

    stub_request(:post, "#{Wechat::Client::SEND_URL}token").
      with(:body => { touser: "12345", msgtype: "news", news: { articles: [{ title: "Hello world", description: "description", picurl: "picurl" }] } }.to_json ).
      to_return(:status => 200, :body => { errmsg: "ok" }.to_json, :headers => {})


  end

  context 'refresh an access code' do
    subject {
      Wechat::Client.new("app_id", "secret")
    }

    it { expect(subject.get_token).to eql(['token', 7200])}
  end

  context 'request an access code that gets cached' do
    subject {
      Wechat::Client.new("app_id", "secret", "token")
    }

    it { expect(subject.has_token?).to eql(true) }
    it { expect(subject.send_message('12345', 'Hello world')).to be true }
    it { expect(subject.send_rich_media_message('12345', 'Hello world', 'description', 'picurl')).to be true }
  end
end