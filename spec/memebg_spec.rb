require 'meme_captain'

describe MemeCaptain, '.memebg' do

  it 'generates a pie slice meme background image' do
    size = 100
    colors = %w{red blue yellow #bada55}
    m = MemeCaptain.memebg(size, colors, 20)

    expect(m.columns).to eq(size)
    expect(m.rows).to eq(size)
  end

end
