require 'meme_captain'

describe MemeCaptain::NormParams do

  def check(input, expected)
    norm_params = MemeCaptain::NormParams.new(input)
    expected.each { |k,v| norm_params.send(k).should == v }
  end

  it 'should leave u as the default if u is not passed in' do
    check({}, { :u => '' })
  end

  it 'should set u to the empty string if u is passed in as nil' do
    check({ :u => nil }, { :u => '' })
  end

  it 'should set the u param' do
    check({ :u => 'foo' }, { :u => 'foo' })
  end

  it 'should leave t1 as the default if t1 is not passed in' do
    check({}, { :t1 => '' })
  end

  it 'should set t1 to the empty string if t1 is passed in as nil' do
    check({ :t1 => nil }, { :t1 => '' })
  end

  it 'should set the t1 param' do
    check({ :t1 => 'foo' }, { :t1 => 'foo' })
  end

  it 'should leave t2 as the default if t2 is not passed in' do
    check({}, { :t2 => '' })
  end

  it 'should set t2 to the empty string if t2 is passed in as nil' do
    check({ :t2 => nil }, { :t2 => '' })
  end

  it 'should set the t2 param' do
    check({ :t2 => 'foo' }, { :t2 => 'foo' })
  end

  it 'should leave t1x as the default if t1x is not passed in' do
    check({}, { :t1x => 0.05 })
  end

  it 'should leave t1x as the default if t1x is passed in as nil' do
    check({ :t1x => nil }, { :t1x => 0.05 })
  end

  it 'should leave t1x as the default if t1x is passed in as the empty string' do
    check({ :t1x => '' }, { :t1x => 0.05 })
  end

  it 'should convert a float t1x to a float' do
    check({ :t1x => '1.2' }, { :t1x => 1.2 })
  end

  it 'should convert an integer t1x to an integer' do
    check({ :t1x => '34' }, { :t1x => 34 })
  end

  it 'should leave t1y as the default if t1y is not passed in' do
    check({}, { :t1y => 0 })
  end

  it 'should leave t1y as the default if t1y is passed in as nil' do
    check({ :t1y => nil }, { :t1y => 0 })
  end

  it 'should leave t1y as the default if t1y is passed in as the empty string' do
    check({ :t1y => '' }, { :t1y => 0 })
  end

  it 'should convert a float t1y to a float' do
    check({ :t1y => '1.2' }, { :t1y => 1.2 })
  end

  it 'should convert an integer t1y to an integer' do
    check({ :t1y => '34' }, { :t1y => 34 })
  end

  it 'should leave t1w as the default if t1w is not passed in' do
    check({}, { :t1w => 0.9 })
  end

  it 'should leave t1w as the default if t1w is passed in as nil' do
    check({ :t1w => nil }, { :t1w => 0.9 })
  end

  it 'should leave t1w as the default if t1w is passed in as the empty string' do
    check({ :t1w => '' }, { :t1w => 0.9 })
  end

  it 'should convert a float t1w to a float' do
    check({ :t1w => '1.2' }, { :t1w => 1.2 })
  end

  it 'should convert an integer t1w to an integer' do
    check({ :t1w => '34' }, { :t1w => 34 })
  end

  it 'should leave t1h as the default if t1h is not passed in' do
    check({}, { :t1h => 0.25 })
  end

  it 'should leave t1h as the default if t1h is passed in as nil' do
    check({ :t1h => nil }, { :t1h => 0.25 })
  end

  it 'should leave t1h as the default if t1h is passed in as the empty string' do
    check({ :t1h => '' }, { :t1h => 0.25 })
  end

  it 'should convert a float t1h to a float' do
    check({ :t1h => '1.2' }, { :t1h => 1.2 })
  end

  it 'should convert an integer t1h to an integer' do
    check({ :t1h => '34' }, { :t1h => 34 })
  end

  it 'should leave t2x as the default if t2x is not passed in' do
    check({}, { :t2x => 0.05 })
  end

  it 'should leave t2x as the default if t2x is passed in as nil' do
    check({ :t2x => nil }, { :t2x => 0.05 })
  end

  it 'should leave t2x as the default if t2x is passed in as the empty string' do
    check({ :t2x => '' }, { :t2x => 0.05 })
  end

  it 'should convert a float t2x to a float' do
    check({ :t2x => '1.2' }, { :t2x => 1.2 })
  end

  it 'should convert an integer t2x to an integer' do
    check({ :t2x => '34' }, { :t2x => 34 })
  end

  it 'should leave t2y as the default if t2y is not passed in' do
    check({}, { :t2y => 0.75 })
  end

  it 'should leave t2y as the default if t2y is passed in as nil' do
    check({ :t2y => nil }, { :t2y => 0.75 })
  end

  it 'should leave t2y as the default if t2y is passed in as the empty string' do
    check({ :t2y => '' }, { :t2y => 0.75 })
  end

  it 'should convert a float t2y to a float' do
    check({ :t2y => '1.2' }, { :t2y => 1.2 })
  end

  it 'should convert an integer t2y to an integer' do
    check({ :t2y => '34' }, { :t2y => 34 })
  end

  it 'should leave t2w as the default if t2w is not passed in' do
    check({}, { :t2w => 0.9 })
  end

  it 'should leave t2w as the default if t2w is passed in as nil' do
    check({ :t2w => nil }, { :t2w => 0.9 })
  end

  it 'should leave t2w as the default if t2w is passed in as the empty string' do
    check({ :t2w => '' }, { :t2w => 0.9 })
  end

  it 'should convert a float t2w to a float' do
    check({ :t2w => '1.2' }, { :t2w => 1.2 })
  end

  it 'should convert an integer t2w to an integer' do
    check({ :t2w => '34' }, { :t2w => 34 })
  end

  it 'should leave t2h as the default if t2h is not passed in' do
    check({}, { :t2h => 0.25 })
  end

  it 'should leave t2h as the default if t2h is passed in as nil' do
    check({ :t2h => nil }, { :t2h => 0.25 })
  end

  it 'should leave t2h as the default if t2h is passed in as the empty string' do
    check({ :t2h => '' }, { :t2h => 0.25 })
  end

  it 'should convert a float t2h to a float' do
    check({ :t2h => '1.2' }, { :t2h => 1.2 })
  end

  it 'should convert an integer t2h to an integer' do
    check({ :t2h => '34' }, { :t2h => 34 })
  end

  it 'should generate the correct signature' do
    MemeCaptain::NormParams.new(
      :t1 => 'text 1',
      :t1h => '1',
      :t1w => '2',
      :t1x => '3',
      :t1y => '4',
      :t2 => 'text 2',
      :t2h => '5',
      :t2w => '6',
      :t2x => '7',
      :t2y => '8',
      :u => 'some u'
     ).signature.should ==
      't1text 1t1h1t1w2t1x3t1y4t2text 2t2h5t2w6t2x7t2y8usome u'
  end

end
