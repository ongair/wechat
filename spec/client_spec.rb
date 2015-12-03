require 'spec_helper'

describe Wechat::Client do
  received_message = <<-EOS
<xml><ToUserName><![CDATA[gh_283218b72e]]></ToUserName><FromUserName><![CDATA[odmSit8iRc_AdaTrWoEGabw4nVd8]]></FromUserName><CreateTime>1436349944</CreateTime><MsgType><![CDATA[text]]></MsgType><Content><![CDATA[Hi]]></Content><MsgId>6169076035298417306</MsgId></xml>
EOS
  let(:message){'Hello world'}
  let(:media_id){'MEDIA_ID'}
  let(:app_id){'app_id'}
  let(:secret){'secret'}
  let(:to_user){'12345'}
  let(:customer_token){'customer_token'}
  let(:we_chat_client){Wechat::Client.new(app_id, secret, customer_token)}
  let(:echostr){('a'..'z').to_a.shuffle[0,16].join}
  let(:nonce){SecureRandom.random_number(100000000).to_s}
  let(:timestamp){Time.now.to_i.to_s}
  let(:signature){Digest::SHA1.hexdigest [customer_token, timestamp, nonce].sort.join}
  let(:access_token){we_chat_client.access_token}

  before do
    stub_request(:get, "#{Wechat::AccessToken::ACCESS_TOKEN_URL}?appid=app_id&grant_type=client_credential&secret=secret").
      to_return(:status => 200, :body => { "access_token" => "token_within_client", "expires_in" => 7200}.to_json, :headers => {})


  end

  context 'can authenticate to receive a new message' do
    it do
      expect(we_chat_client.access_token).to eql(nil)
      expect(we_chat_client.authenticate(nonce, signature, timestamp)).to be(true)
      expect(we_chat_client.authenticate("nonce", signature, timestamp)).to be(false)
    end
  end

  context 'Skip authentication if set to false' do
    it do
      client = Wechat::Client.new('Chinese', SecureRandom.hex, SecureRandom.hex, false)
      expect(client.authenticate("blah", "blah blah", "blah blah blah")).to be(true)
    end
  end

  context 'can receive message' do
    it do
      expect(we_chat_client.access_token).to eql(nil)
      expect(we_chat_client.receive_message(received_message)['ToUserName']).to eq('gh_283218b72e')
      expect(we_chat_client.receive_message(received_message)['FromUserName']).to eq('odmSit8iRc_AdaTrWoEGabw4nVd8')
      expect(we_chat_client.receive_message(received_message)['MsgType']).to eq('text')
      expect(we_chat_client.receive_message(received_message)['Content']).to eq('Hi')
      expect(we_chat_client.receive_message(received_message)['MsgId']).to eq('6169076035298417306')
    end
  end

  context 'can send a message' do
    it do
      expect(we_chat_client.access_token).to eql(nil)

      expect(HTTParty).to receive(:post).with("#{Wechat::Client::SEND_URL}token_within_client",
        {:body=>"{\"touser\":\"12345\",\"msgtype\":\"text\",\"text\":{\"content\":\"Hello world\"}}",
        debug_output: $stdout} ).and_return(true)

      expect(we_chat_client.send_message(to_user,'text',message)).to be(true)
      expect(we_chat_client.access_token).to eql('token_within_client')
    end
  end

  context 'can send an image' do
    it do
      file = File.open('spec/files/wechat.jpg')

      response = {}
      
      expect(response).to receive(:body).and_return({ media_id: '12345' }.to_json)
      expect(HTTMultiParty).to receive(:post).with("#{Wechat::Client::UPLOAD_URL}token_within_client",
        {body: { type: 'Image', media: file }, debug_output: $stdout}).and_return(response)

      expect(HTTParty).to receive(:post).with("#{Wechat::Client::SEND_URL}token_within_client",
        {:body => "{\"touser\":\"12345\",\"msgtype\":\"image\",\"image\":{\"media_id\":\"12345\"}}",
        debug_output: $stdout} ).and_return(true)

      expect(we_chat_client.send_image(to_user, file)).to be(true)
    end
  end

  context 'can get a file attachment url' do
    it do
      url = "#{Wechat::Client::FILE_URL}token_within_client&media_id=12345"
      expect(we_chat_client.get_media_url('12345')).to eql(url)
    end
  end

  context 'can send a multimedia message' do
    it do
      expect(we_chat_client.access_token).to eql(nil)
      url = 'www.google.com/images/branding/googlelogo/1x/googlelogo_color_150x54dp.png'

      expect(HTTParty).to receive(:post).with("#{Wechat::Client::SEND_URL}token_within_client",
        { body: { touser: '12345', msgtype: 'news', news: { articles: [{ title: 'Attachment', description: 'See Attachment', picurl: url }]} }.to_json,
        debug_output: $stdout} ).and_return(true)

      expect(we_chat_client.send_rich_media_message(to_user,'Attachment', 'See Attachment', url)).to be(true)

    end
  end

  context 'raises error if message refuses to send' do
    it do
      expect(we_chat_client.access_token).to eql(nil)
      expect(HTTParty).to receive(:post).with("#{Wechat::Client::SEND_URL}token_within_client",
        {:body=>"{\"touser\":\"12345\",\"msgtype\":\"text\",\"text\":{\"content\":\"Hello world\"}}",
        debug_output: $stdout} ).and_return(false)

      expect { we_chat_client.send_message(to_user,'text',message) }.to raise_error(RuntimeError)
    end
  end

end
