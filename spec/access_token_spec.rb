require 'spec_helper'

describe Wechat::AccessToken do
  let(:app_id){'app_id'}
  let(:secret){'secret'}
  let(:redis){Redis.new}

  context 'An existing token is saved' do
    it 'Can handle a valid token from redis' do
      hash = Hash['access_token','token1','expires_in',7200, 'time_stamp', (Time.now - 6600).to_i]
      redis.set app_id, hash.to_json

      token = Wechat::AccessToken.new(app_id, secret)

      expect(token.is_valid?).to eql(true)
      expect(token.has_error?).to eql(false)
      expect(token.access_token).to eql('token1')
    end

    it 'Can handle an expired token' do
      hash = Hash['access_token','token1','expires_in',7200, 'time_stamp', (Time.now - 7205).to_i, 'new_token_requested', false]
      redis.set app_id, hash.to_json

      token = Wechat::AccessToken.new(app_id, secret)

      expect(token.is_valid?).to eql(false)
      expect(token.has_error?).to eql(false)
    end

    it 'Can handle an error in a saved token' do
      hash = Hash['errcode', 40125, 'errmsg', "invalid appsecret, view more at http://t.cn/RAEkdVq hint: [jsDxoa0928szc8]", "time_stamp", 1468414929 ]
      redis.set app_id, hash.to_json

      token = Wechat::AccessToken.new(app_id, secret)
      expect(token.is_valid?).to eql(false)
      expect(token.has_error?).to eql(true)
    end
  end

  context 'Getting token from wechat' do
    it 'Can load a token if nothing is saved' do
      token = Wechat::AccessToken.new(app_id, secret)

      expect(token.is_valid?).to eql(false)
      expect(token.has_error?).to eql(false)

      stub = stub_request(:get, "#{Wechat::AccessToken::ACCESS_TOKEN_URL}?appid=#{app_id}&grant_type=client_credential&secret=#{secret}")
        .to_return(:status => 200, :body => { "access_token" => "token", "expires_in" => 7200}.to_json, :headers => {})

      token.refresh
      assert_requested stub

      expect(token.is_valid?).to eql(true)
      expect(token.has_error?).to eql(false)
    end

    it 'Can handle if a token fetch has an error' do
      stub = stub_request(:get, "#{Wechat::AccessToken::ACCESS_TOKEN_URL}?appid=#{app_id}&grant_type=client_credential&secret=#{secret}").
        to_return(:status => 200, :body => { "errcode" => 40125, "errmsg" => "invalid appsecret, view more at http://t.cn/RAEkdVq hint: [jsDxoa0928szc8]", "time_stamp" => 1468414929 }.to_json, :headers => {})

      token = Wechat::AccessToken.new(app_id, secret)

      expect(token.is_valid?).to eql(false)
      expect(token.has_error?).to eql(false)

      token.refresh
      assert_requested stub

      expect(token.is_valid?).to eql(false)
      expect(token.has_error?).to eql(true)

      expect{token.access_token}.to raise_error(Wechat::AccessTokenException)
    end
  end

  describe 'if there is a problem with getting the access code' do
    context 'if the app secret is invalid' do

      it do
        stub_request(:get, "#{Wechat::AccessToken::ACCESS_TOKEN_URL}?appid=#{app_id}&grant_type=client_credential&secret=#{secret}").
          to_return(:status => 200, :body => { "errcode" => 40125, "errmsg" => "invalid appsecret, view more at http://t.cn/RAEkdVq hint: [jsDxoa0928szc8]", "time_stamp" => 1468414929 }.to_json, :headers => {})

        token = Wechat::AccessToken.new(app_id, secret)
        expect{token.access_token}.to raise_error(Wechat::AccessTokenException)
      end
    end
  end

  describe 'if there is a problem with getting the access code it retries' do
    context 'if the app secret is invalid' do

      4.times do |n|
        it do
          stub_request(:get, "#{Wechat::AccessToken::ACCESS_TOKEN_URL}?appid=#{app_id}&grant_type=client_credential&secret=#{secret}").
            to_return(:status => 200, :body => { "errcode" => 40125, "errmsg" => "invalid appsecret, view more at http://t.cn/RAEkdVq hint: [jsDxoa0928szc8]", "time_stamp" => 1468414929 }.to_json, :headers => {})
          if n < 3
            token = Wechat::AccessToken.new(app_id, secret)
            expect{token.access_token}.to raise_error(Wechat::AccessTokenException)
          else
            # TODO: This does not make sense...
            # expect(JSON.parse(redis.get(app_id))['retries']).to eql(n+1)
          end
        end
      end

    end
  end

end
