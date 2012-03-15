require 'meme_captain'

describe MemeCaptain::TextPos do

  it 'should store the required fields' do
    t = MemeCaptain::TextPos.new('text', 0, 25, 50, 100)
    t.text.should == 'text'
    t.x.should == 0
    t.y.should == 25
    t.width.should == 50
    t.height.should == 100
  end

  it 'should store the max_lines option' do
    MemeCaptain::TextPos.new('text', 0, 25, 50, 100,
      :max_lines => 10).max_lines.should == 10
  end

  it 'should store the min_pointsize option' do
    MemeCaptain::TextPos.new('text', 0, 25, 50, 100,
      :min_pointsize => 11).min_pointsize.should == 11
  end

  it 'should pass store additional options in draw_options' do
    MemeCaptain::TextPos.new('text', 0, 25, 50, 100,
      :font => 'Comic Sans').draw_options[:font].should == 'Comic Sans'
  end

end
