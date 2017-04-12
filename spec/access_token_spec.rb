require 'spec_helper'

describe Wechat::AccessToken do
  let(:app_id){'app_id'}
  let(:secret){'secret'}
  let(:redis){Redis.new}

  before do
    stub_request(:get, "#{Wechat::AccessToken::ACCESS_TOKEN_URL}?appid=#{app_id}&grant_type=client_credential&secret=#{secret}").
      to_return(:status => 200, :body => { "access_token" => "token", "expires_in" => 7200}.to_json, :headers => {})
  end

  context 'get a new access code' do
    subject {
      Wechat::AccessToken.new(app_id, secret)
    }
    it do
      expect(subject.access_token).to eql('token')
      expect(JSON.parse(redis.get(app_id))['access_token']).to eql('token')
      expect(JSON.parse(redis.get(app_id))['expires_in']).to eql(7200)
   end
  end

  describe 'if token is valid for less than 1 minute' do
    before do
      hash = Hash['access_token','token1','expires_in',7200, 'time_stamp', (Time.now - 7141).to_i]
      redis.set app_id, hash.to_json
    end

    context 'return cached access_token and fetch new one' do
      subject {
        Wechat::AccessToken.new(app_id, secret)
      }

      it do
        expect(subject.access_token).to eql('token')
        expect(JSON.parse(redis.get(app_id))['access_token']).to eql('token') #new access_token
        expect(JSON.parse(redis.get(app_id))['expires_in']).to eql(7200)
     end
    end
  end

  describe 'if token has expired' do
    before do
      hash = Hash['access_token','token1','expires_in',7200, 'time_stamp', (Time.now - 7205).to_i, 'new_token_requested', false]
      redis.set app_id, hash.to_json
    end

    context 'fetch and return a new access token' do
      subject {
        Wechat::AccessToken.new(app_id, secret)
      }
      it do
        expect(subject.access_token).to eql('token')
        expect(JSON.parse(redis.get(app_id))['access_token']).to eql('token')
        expect(JSON.parse(redis.get(app_id))['expires_in']).to eql(7200)
     end
    end
  end

  # describe 'if there is a problem with getting the access code' do
  #   context 'if the app secret is invalid' do

  #     it do
  #       stub_request(:get, "#{Wechat::AccessToken::ACCESS_TOKEN_URL}?appid=#{app_id}&grant_type=client_credential&secret=#{secret}").
  #         to_return(:status => 200, :body => { "errcode" => 40125, "errmsg" => "invalid appsecret, view more at http://t.cn/RAEkdVq hint: [jsDxoa0928szc8]", "time_stamp" => 1468414929 }.to_json, :headers => {})

  #       token = Wechat::AccessToken.new(app_id, secret)        
  #       expect{token.access_token}.to raise_error(Wechat::AccessTokenException)
  #     end
  #   end
  # end

  describe 'if there is a problem with getting the access code it retries' do
    context 'if the app secret is invalid' do

      before do
        hash = Hash['access_token', nil, 'retries', 0]
        redis.set app_id, hash.to_json
      end

      4.times do |n|
        it do
          stub_request(:get, "#{Wechat::AccessToken::ACCESS_TOKEN_URL}?appid=#{app_id}&grant_type=client_credential&secret=#{secret}").
            to_return(:status => 200, :body => { "errcode" => 40125, "errmsg" => "invalid appsecret, view more at http://t.cn/RAEkdVq hint: [jsDxoa0928szc8]", "time_stamp" => 1468414929 }.to_json, :headers => {})

          puts ">>>>>>> #{redis.get(app_id)}"

          if n < 3
            expect(JSON.parse(redis.get(app_id))['retries']).to eql(n+1)        
          else
            token = Wechat::AccessToken.new(app_id, secret)
            expect{token.access_token}.to raise_error(Wechat::AccessTokenException)
          end
        end
      end

    end
  end

end
