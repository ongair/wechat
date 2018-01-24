require 'spec_helper'

describe Wechat::Emoji do

  context 'Can parse incoming emoji' do
    it 'Can check for nil text' do
      expect(Wechat::Emoji.has_emoji?(nil)).to be(false)
    end

    it 'Can check for text that has no emoji' do
      expect(Wechat::Emoji.has_emoji?('Skip to my loo')).to be(false)
    end

    it 'Can detect word based escaped emoji' do
      text = '/:skip to my loo'
      expect(Wechat::Emoji.has_emoji?(text)).to be(true)
    end

    it 'Can detect non word based escaped emoji' do
      text = '/::)'
      expect(Wechat::Emoji.has_emoji?(text)).to be(true)
    end

    it 'Can detect all the emojis' do
      Wechat::Emoji::EMOJI.keys.each do |key|
        # puts "Key #{key}"
        expect(Wechat::Emoji.has_emoji?(key)).to be(true)
      end
    end
  end

  context 'replacing with unicode' do

    it 'if no emoji are present the same text is returned' do
      text = 'Happy birthday'
      expect(Wechat::Emoji.replace_with_unicode(text)).to eql(text)
    end

    it 'can detect a smiley emoji' do
      text = "I want to /::) but it comes out as a /::|/::<"
      expect(Wechat::Emoji.replace_with_unicode(text)).to eql("I want to \u{1F600} but it comes out as a \u{1f621}\u{1f62d}")

      text = "When I /::'( i want to /::Z"
      expect(Wechat::Emoji.replace_with_unicode(text)).to eql("When I \u{1F622} i want to \u{1f634}")
    end
  end
end
