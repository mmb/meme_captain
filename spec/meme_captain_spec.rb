require 'digest/sha1'
require 'open-uri'
require 'tempfile'

require 'meme_captain'

describe MemeCaptain, '.meme_top_bottom' do

  it 'generates a meme image with text at the top and bottom' do
    i = MemeCaptain.meme_top_bottom(
      open('http://memecaptain.com/troll_face.jpg'), 'top text', 'bottom text')
    path = Tempfile.new('meme_captain_test').path
    i.write path
    open(path) do |f|
      Digest::SHA1.hexdigest(f.read).should ==
        '59b57d624d2cd6f0e10e1b1e25221673c192b602'
    end
  end

end
