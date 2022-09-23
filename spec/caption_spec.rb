require 'meme_captain'

describe MemeCaptain::Caption do

  it 'should quote backslashes for ImageMagick annotate' do
    expect(MemeCaptain::Caption.new('\\foo\\bar\\').annotate_quote).to eq(
      '\\\\foo\\\\bar\\\\')
  end

  it 'should quote percent signs for ImageMagick annotate' do
    expect(MemeCaptain::Caption.new('%foo%bar%').annotate_quote).to eq(
      '%%foo%%bar%%')
  end

  it 'should quote attribute percent escapes' do
    expect(MemeCaptain::Caption.new('%m %m %b %#').annotate_quote).to eq(
      '%%m %%m %%b %%#')
  end

  it 'should quote an @ symbol if it is the first character' do
    expect(MemeCaptain::Caption.new('@hi').annotate_quote).to eq('\@hi')
  end

  it 'should be drawable if it contains at least one non-whitespace character' do
    expect(MemeCaptain::Caption.new('a').drawable?).to be(true)
  end

  it 'should not be drawable if it is all whitespace' do
    expect(MemeCaptain::Caption.new('    ').drawable?).to be(false)
  end

  it 'should not be drawable if it is empty' do
    expect(MemeCaptain::Caption.new('').drawable?).to be(false)
  end

  it 'should not be drawable if it is nil' do
    expect(MemeCaptain::Caption.new(nil).drawable?).to be(false)
  end

  it 'should wrap a string into two roughly equal lines' do
    expect(MemeCaptain::Caption.new(
      'the quick brown fox jumped over the lazy dog').wrap(2)).to eq(
      "the quick brown fox\njumped over the lazy dog")
  end

  it 'should wrap a string into as many lines as it can' do
    expect(MemeCaptain::Caption.new('foo bar').wrap(3)).to eq("foo\nbar")
  end

  it 'should not wrap text with no whitespace' do
    expect(MemeCaptain::Caption.new('foobar').wrap(2)).to eq('foobar')
  end

  it 'should return Caption instance after upcase' do
    result = MemeCaptain::Caption.new('foobar').upcase
    expect(result).to eq('FOOBAR')
    expect(result.class).to eq(MemeCaptain::Caption)
  end

end
