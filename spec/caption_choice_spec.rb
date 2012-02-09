require 'meme_captain'

describe MemeCaptain::CaptionChoice do

  it 'should rank choices with text that fits higher' do
    metrics = double('metrics', :width => 200, :height => 100)

    caption_choice1 = MemeCaptain::CaptionChoice.new(12, metrics,
      "the quick brown fox", 200, 99)

    caption_choice2 = MemeCaptain::CaptionChoice.new(12, metrics,
      "the quick brown fox", 200, 100)

    caption_choice1.should be < caption_choice2
  end

  it 'should rank choices with higher point size higher' do
    metrics = double('metrics', :width => 200, :height => 100)

    caption_choice1 = MemeCaptain::CaptionChoice.new(12, metrics,
      "the quick brown fox", 200, 100)

    caption_choice2 = MemeCaptain::CaptionChoice.new(13, metrics,
      "the quick brown fox", 200, 100)

    caption_choice1.should be < caption_choice2
  end

  it 'should rank choices with less lines higher when the text fits' do
    metrics = double('metrics', :width => 200, :height => 100)

    caption_choice1 = MemeCaptain::CaptionChoice.new(12, metrics,
      "the quick\nbrown fox", 200, 100)

    caption_choice2 = MemeCaptain::CaptionChoice.new(12, metrics,
      "the quick brown fox", 200, 100)

    caption_choice1.should be < caption_choice2
  end

  it 'should rank choices with more lines higher when the text does not fit' do
    metrics = double('metrics', :width => 200, :height => 100)

    caption_choice1 = MemeCaptain::CaptionChoice.new(12, metrics,
      "the quick brown fox", 200, 99)

    caption_choice2 = MemeCaptain::CaptionChoice.new(12, metrics,
      "the quick\nbrown fox", 200, 99)

    caption_choice1.should be < caption_choice2
  end

end
