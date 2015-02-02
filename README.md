# Wechat

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'wechat', git: 'https://github.com/sproutke/wechat.git'
```

And then execute:

    $ bundle

## Usage

### Parsing WeChat xml messages

WeChat notifies your server by posting xml messages.

```
  require 'wechat'
  
  xml = "<xml><ToUserName><![CDATA[your_id]]></ToUserName>\n<FromUserName><![CDATA[contact_id]]></FromUserName>\n<CreateTime>create_time</CreateTime>\n<MsgType><![CDATA[text]]></MsgType>\n<Content><![CDATA[The message]]></Content>\n<MsgId>Id</MsgId>\n</xml>"

  def notification = Notification.new(xml)
  puts notification.notification_type #text
  puts notification.is_message? #true
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/wechat/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
