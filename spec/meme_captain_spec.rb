require 'open-uri'

require 'meme_captain'

describe MemeCaptain, '.meme_top_bottom' do

  it 'generates a meme image with text at the top and bottom' do
    i = MemeCaptain.meme_top_bottom(
      open('http://memecaptain.com/troll_face.jpg'), 'top text', 'bottom text')
    i.display
  end

end
