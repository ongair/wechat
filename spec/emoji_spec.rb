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
      text = '/:<L>'
      expect(Wechat::Emoji.has_emoji?(text)).to be(true)
    end
  end
end
