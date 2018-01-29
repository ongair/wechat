module Wechat
  class Emoji

    def self.has_emoji? text
      return !text.nil? && !text.match(EMOJI_REGEX).nil?
    end

    def self.replace_with_unicode text
      if self.has_emoji?(text)
        matches = text.scan(EMOJI_REGEX)
        matches.each do |match|
          key = "/:#{match.first}"

          emoji = EMOJI[key]
          text.gsub!(emoji[:regex], emoji[:unicode])
        end
      end
      text
    end

    def self.print_out
      EMOJI.each do |key,emoji|
        puts "#{emoji[:name]}-#{emoji[:unicode]}-#{!key.match(emoji[:regex]).nil?}"
      end
    end

    EMOJI_REGEX = /\/:(:\)|:~|:[A-Z]|:\||8-\)|:<|:\$|:'\(|:-\||:@|:\(|:\+|--b|,@P|,@-D|:d|,@o|:g|\|-\)|:!|:L|:>|:,@|,@f|:-S|\?|,@x|,@@|:8|,@!|!!!|&-\(|B-\)|<@|>@|@>|:-O|>-\||P-\(|:'\||X-\)|:\*|@x|8\*|@\)|@{2}|<[A-Z]>|[a-zA-Z]+)/
    EMOJI = {
      "/::)" => { name: "smile", unicode: "\u{1F600}", regex: /\/::\)/ }, #\u{1F600}
      "/::~" => { name: "grimace", unicode: "\u{1F62C}", regex: /\/::~/ },
      "/::B" => { name: "drool", unicode: "\u{1F60D}", regex: /\/::B/ },
      "/::|" => { name: "scowl", unicode: "\u{1F621}", regex: /\/::\|/ },
      "/:8-)" => { name: "cool", unicode: "\u{1f60e}", regex: /\/:8-\)/ },
      "/::<" => { name: "sob", unicode: "\u{1f62d}", regex: /\/::</ },
      "/::$" => { name: "shy", unicode: "\u{1f60a}", regex: /\/::\$/ },
      "/::X" => { name: "silent", unicode: "\u{1f910}", regex: /\/::X/ },
      "/::Z" => { name: "sleep", unicode: "\u{1f634}", regex: /\/::Z/ },
      "/::'(" => { name: "cry", unicode: "\u{1f622}", regex: /\/::'\(/ },
      "/::-|" => { name: "awkward", unicode: "/::-|", regex: /\/::-\|/ }, # no unicode equivalent
      "/::@" => { name: "angry", unicode: "\u{1f620}", regex: /\/::@/ },
      "/::P" => { name: "tongue", unicode: "\u{1f61c}", regex: /\/::P/ },
      "/::D" => { name: "grin", unicode: "\u{1f606}", regex: /\/::D/ },
      "/::O" => { name: "surprise", unicode: "\u{1f62e}", regex: /\/::O/ },
      "/::(" => { name: "frown", unicode: "\u{1F641}", regex: /\/::\(/ },
      "/::+" => { name: "ruthless", unicode: "/::+", regex: /\/::\+/ },
      "/:--b" => { name: "blush", unicode: "\u{1f60a}", regex: /\/:--b/ },
      "/:Q" => { name: "scream", unicode: "\u{1f631}", regex: /\/:Q/ },
      "/:T" => { name: "puke", unicode: "\u{1f922}", regex: /\/:T/ },
      "/:,@P" => { name: "chuckle", unicode: "/:,@P", regex: /\/:,@P/ },
      "/:,@-D" => { name: "joyful", unicode: "\u{1f60a}", regex: /\/:,@-D/ },
      "/::d" => { name: "slight", unicode: "/::d", regex: /\/::d/ },
      "/:,@o" => { name: "smug", unicode: "\u{1f60f}", regex: /\/:,@o/ },
      "/::g" => { name: "hungry", unicode: "\u{1f60b}", regex: /\/::g/ },
      "/:|-)" => { name: "drowsy", unicode: "\u{1f62b}", regex: /\/:\|-/ },
      "/::!" => { name: "panic", unicode: "\u{1f630}", regex: /\/::!/ },
      "/::L" => { name: "sweat", unicode: "\u{1f613}", regex: /\/::L/ },
      "/::,@" => { name: "commando", unicode: "/::,@", regex: /\/::,@/ },
      "/:,@f" => { name: "determined", unicode: "\u{1f623}", regex: /\/:,@f/ },
      "/::-S" => { name: "scold", unicode: "/::-S", regex: /\/::-S/ },
      "/:?" => { name: "shocked", unicode: "\u{1f628}", regex: /\/:\?/ },
      "/:,@x" => { name: "shh", unicode: "/:,@x", regex: /\/:,@x/ },
      "/:,@@" => { name: "dizzy", unicode: "\u{1f635}", regex: /\/:,@@/ },
      "/::8" => { name: "tormented", unicode: "/::8", regex: /\/::8/ },
      "/:,@!" => { name: "toasted", unicode: "/:,@!", regex: /\/:,@!/ },
      "/:!!!" => { name: "skull", unicode: "\u{1f480}", regex: /\/:!!!/ },
      "/:xx" => { name: "hammer", unicode: "\u{1f528}", regex: /\/:xx/ },
      "/:bye" => { name: "bye", unicode: "\u{1f44b}", regex: /\/:bye/ },
      "/:wipe" => { name: "speechless", unicode: "/:wipe", regex: /\/:wipe/ },
      "/:dig" => { name: "dig", unicode: "/:dig", regex: /\/:dig/ },
      "/:handclap" => { name: "handclap", unicode: "\u{1f44f}", regex: /\/:handclap/ },
      "/:&-(" => { name: "shame", unicode: "/:&-(", regex: /\/:&-\(/ },
      "/:B-)" => { name: "trick", unicode: "/:B-)", regex: /\/:B-\)/ },
      "/:<@" => { name: "bah-left", unicode: "\u{1f621}", regex: /\/:<@/ },
      "/:>@" => { name: "bah-right", unicode: "\u{1f621}", regex: /\/:>@/ },
      "/::-O" => { name: "yawn", unicode: "\u{1f62b}", regex: /\/::-O/ },
      "/:>-|" => { name: "pooh pooh", unicode: "/:>-|", regex: /\/:>-\|/ },
      "/:P-(" => { name: "shrunken", unicode: "/:P-(", regex: /\/:P-\(/ },
      "/::'|" => { name: "tearing up", unicode: "/::'|", regex: /\/::'\|/ },
      "/:X-)" => { name: "sly", unicode: "/:X-)", regex: /\/:X-\)/ },
      "/::*" => { name: "kiss", unicode: "\u{1f617}", regex: /\/::\*/ },
      "/:@x" => { name: "wrath", unicode: "/:@x", regex: /\/:@x/ },
      "/:8*" => { name: "whimper", unicode: "/:8*", regex: /\/:8\*/ },
      "/:pd" => { name: "knife", unicode: "\u{1f52a}", regex: /\/:pd/ },
      "/:<W>" => { name: "watermelon", unicode: "\u{1f349}", regex: /\/:<W>/ },
      "/:beer" => { name: "beer", unicode: "\u{1f37a}", regex: /\/:beer/ },
      "/:basketb" => { name: "basketball", unicode: "\u{1f3c0}", regex: /\/:basketb/ },
      "/:oo" => { name: "ping pong", unicode: "\u{1f3d3}", regex: /\/:oo/ },
      "/:coffee" => { name: "coffee", unicode: "\u{2615}", regex: /\/:coffee/ },
      "/:eat" => { name: "knife", unicode: "\u{1f35a}", regex: /\/:eat/ },
      "/:pig" => { name: "pig", unicode: "\u{1f437}", regex: /\/:pig/ },
      "/:rose" => { name: "rose", unicode: "\u{1f339}", regex: /\/:rose/ },
      "/:fade" => { name: "fade", unicode: "\u{1f940}", regex: /\/:fade/ },
      "/:showlove" => { name: "lips", unicode: "\u{1f444}", regex: /\/:showlove/ },
      "/:heart" => { name: "heart", unicode: "\u{2764}", regex: /\/:heart/ },
      "/:break" => { name: "heart-break", unicode: "\u{1f494}", regex: /\/:break/ },
      "/:cake" => { name: "cake", unicode: "\u{1f382}", regex: /\/:cake/ },
      "/:li" => { name: "lighting", unicode: "\u{26a1}", regex: /\/:li/ },
      "/:bome" => { name: "bomb", unicode: "\u{1f4a3}", regex: /\/:bome/ },
      "/:kn" => { name: "dagger", unicode: "\u{1f5e1}", regex: /\/:kn/ },
      "/:footb" => { name: "soccer", unicode: "\u{26bd}", regex: /\/:footb/ },
      "/:ladybug" => { name: "ladybug", unicode: "\u{1f41e}", regex: /\/:ladybug/ },
      "/:shit" => { name: "poop", unicode: "\u{1f4a9}", regex: /\/:shit/ },
      "/:moon" => { name: "moon", unicode: "\u{1f31d}", regex: /\/:moon/ },
      "/:sun" => { name: "sun", unicode: "\u{1f31e}", regex: /\/:sun/ },
      "/:gift" => { name: "gift", unicode: "\u{1f381}", regex: /\/:gift/ },
      "/:hug" => { name: "hug", unicode: "\u{1f917}", regex: /\/:hug/ },
      "/:strong" => { name: "thumbs-up", unicode: "\u{1f44d}", regex: /\/:strong/ },
      "/:weak" => { name: "thumbs-down", unicode: "\u{1f44e}", regex: /\/:weak/ },
      "/:share" => { name: "shake", unicode: "\u{1f91d}", regex: /\/:share/ },
      "/:v" => { name: "peace", unicode: "\u{270c}", regex: /\/:v/ },
      "/:@)" => { name: "pre-fight", unicode: "/:@)", regex: /\/:@\)/ },
      "/:jj" => { name: "beckon", unicode: "/:jj", regex: /\/:jj/ },
      "/:@@" => { name: "raised fist", unicode: "\u{270a}", regex: /\/:@@/ },
      "/:bad" => { name: "pinky", unicode: "/:bad", regex: /\/:bad/ },
      "/:lvu" => { name: "rock on", unicode: "\u{1f918}", regex: /\/:lvu/ },
      "/:no" => { name: "no", unicode: "\u{261d}", regex: /\/:no/ },
      "/:ok" => { name: "ok", unicode: "\u{1f44c}", regex: /\/:ok/ },
      "/:love" => { name: "love", unicode: "\u{1f491}", regex: /\/:love/ },
      "/:<L>" => { name: "<L>", unicode: "/:<L>", regex: /\/:<L>/ },
      "/:jump" => { name: "jump", unicode: "/:jump", regex: /\/:jump/ },
      "/:shake" => { name: "shake", unicode: "/:shake", regex: /\/:shake/ },
      "/:<O>" => { name: "moon", unicode: "/:<O>", regex: /\/:<O>/ },
      "/:circle" => { name: "circle", unicode: "/:circle", regex: /\/:circle/ },
      "/:kotow" => { name: "kotow", unicode: "\u{1f647}", regex: /\/:kotow/ },
      "/:turn" => { name: "turn", unicode: "/:turn", regex: /\/:turn/ },
      "/:skip" => { name: "skip", unicode: "\u{1f937}", regex: /\/:skip/ },
      "/:oY" => { name: "surrender", unicode: "/:oY", regex: /\/:oY/ }
    }

  end
end
