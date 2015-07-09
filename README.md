# Wechat
A gem to interact with the WeChat API.

Currently supporting authentication, access token aquisition, message receipt and the sending of text and image messages.

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'wechat', git: 'https://github.com/sproutke/wechat.git'
```

And then execute:

    $ bundle

## Usage

    require 'wechat'
 ### Receiving messages
 When the WeChat server sends a message it must be authenticated and a response sent back to the WeChat server. The WeChat server expects the unchanged `echostr` as the response upon successful authentication. The WeChat server sends a `POST` request to the submitted URL with four parameters: `signature`, `timestamp`, `nonce` and `echostr` and the message in the body. Developers authenticate the messages by checking the signature parameter and extract the XML message from the body.

 ```ruby
 def receive_message
    we_chat_client = Wechat::Client.new(app_id, secret, customer_token)

    render text: echostr if we_chat_client.authenticate(params[:echostr],params[:nonce],params[:signature], params[:timestamp])
    message = we_chat_client.receive_message(response.body.read)
 end

 message #{"FromUserName"=>"odmSit8iRc_AdaTrWoEGabi4nVd8", "CreateTime"=>"1436355707", "MsgType"=>"text", "Content"=>"How's it going?", "MsgId"=>"6169100787194945124"}
 ```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/wechat/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
