require 'meme_captain'

describe MemeCaptain::Caption do

  it 'should quote backslashes for ImageMagick annotate' do
    MemeCaptain::Caption.new('\\foo\\bar\\').annotate_quote.should ==
      '\\\\foo\\\\bar\\\\'
  end

  it 'should quote percent signs for ImageMagick annotate' do
    MemeCaptain::Caption.new('%foo%bar%').annotate_quote.should ==
      '\%foo\%bar\%'
  end

  it 'should be drawable if it contains at least one non-whitespace character' do
    MemeCaptain::Caption.new('a').should be_drawable
  end

  it 'should not be drawable if it is all whitespace' do
    MemeCaptain::Caption.new('    ').should_not be_drawable
  end

  it 'should not be drawable if it is empty' do
    MemeCaptain::Caption.new('').should_not be_drawable
  end

  it 'should not be drawable if it is nil' do
    MemeCaptain::Caption.new(nil).should_not be_drawable
  end

  it 'should wrap a string into two roughly equal lines' do
    MemeCaptain::Caption.new(
      'the quick brown fox jumped over the lazy dog').wrap(2).should ==
      "the quick brown fox\njumped over the lazy dog"
  end

  it 'should wrap a string into as many lines as it can' do
    MemeCaptain::Caption.new('foo bar').wrap(3).should == "foo\nbar"
  end

  it 'should not wrap text with no whitespace' do
    MemeCaptain::Caption.new('foobar').wrap(2).should == 'foobar'
  end

end
