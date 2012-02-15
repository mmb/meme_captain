require 'base64'
require 'open-uri'

require 'webmock/rspec'

require 'meme_captain'

describe MemeCaptain, '.meme_top_bottom' do

  it 'generates a meme image with text at the top and bottom' do
    stub_request(:get, 'http://memecaptain.com/good.jpg').to_return(
      :body => Base64.decode64(
        'iVBORw0KGgoAAAANSUhEUgAAAcwAAAAyAgMAAACsWgPIAAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9wBHwQoJY1iyrwAAAAJUExURQAAAAAAAP///4Pdz9IAAAABdFJOUwBA5thmAAAAAWJLR0QB/wIt3gAAAHpJREFUWIXt1zESgCAMRNE03s9mG+9ns6e0EaKCqDOWf4sUJOHREvqciOn7Us0cEZiYmJhnc7HtVbJtS5LsVRo09DScZzmSG5iYmJit2RTVlduGquS920hFvxRMTEzMRzOv6TfKheMX9ThMTEzMnvlj5ld/S0xMTMxjNoGjc3pdi6L4AAAAAElFTkSuQmCC'))

    i = MemeCaptain.meme_top_bottom(
      open('http://memecaptain.com/good.jpg'), 'top text', 'bottom text')
  end

end
