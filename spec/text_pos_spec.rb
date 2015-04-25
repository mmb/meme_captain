require 'meme_captain'

describe MemeCaptain::TextPos do

  it 'should store the required fields' do
    t = MemeCaptain::TextPos.new('text', 0, 25, 50, 100)
    expect(t.text).to eq('text')
    expect(t.x).to eq(0)
    expect(t.y).to eq(25)
    expect(t.width).to eq(50)
    expect(t.height).to eq(100)
  end

  it 'should store the max_lines option' do
    expect(MemeCaptain::TextPos.new('text', 0, 25, 50, 100,
      :max_lines => 10).max_lines).to eq(10)
  end

  it 'should store the min_pointsize option' do
    expect(MemeCaptain::TextPos.new('text', 0, 25, 50, 100,
      :min_pointsize => 11).min_pointsize).to eq(11)
  end

  it 'should pass store additional options in draw_options' do
    expect(MemeCaptain::TextPos.new('text', 0, 25, 50, 100,
      :font => 'Comic Sans').draw_options[:font]).to eq('Comic Sans')
  end

end
