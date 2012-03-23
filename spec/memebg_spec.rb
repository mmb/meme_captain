require 'meme_captain'

describe MemeCaptain, '.memebg' do

  it 'generates a pie slice meme background image' do
    size = 100
    colors = %w{red blue yellow #bada55}
    m = MemeCaptain.memebg(size, colors, 20)

    m.columns.should == size
    m.rows.should == size
  end

end
