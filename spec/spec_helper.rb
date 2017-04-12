$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'wechat'
require 'access_token'
require 'webmock/rspec'
require 'redis_test'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.color = true

  config.before(:suite) do
      RedisTest.start
    end

    config.after(:each) do
      RedisTest.clear
      # notice that will flush the Redis db, so it's less
      # desirable to put that in a config.before(:each) since it may clean any
      # data that you try to put in redis prior to that
    end

    config.after(:suite) do
      RedisTest.stop
    end
end
