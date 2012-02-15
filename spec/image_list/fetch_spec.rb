require 'base64'

require 'RMagick'
require 'webmock/rspec'

require 'meme_captain'

describe MemeCaptain::ImageList::Fetch do

  it 'should load an image from a URL' do
    stub_request(:get, 'http://memecaptain.com/good.jpg').to_return(
      :body => Base64.decode64(
        'iVBORw0KGgoAAAANSUhEUgAAAcwAAAAyAgMAAACsWgPIAAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9wBHwQoJY1iyrwAAAAJUExURQAAAAAAAP///4Pdz9IAAAABdFJOUwBA5thmAAAAAWJLR0QB/wIt3gAAAHpJREFUWIXt1zESgCAMRNE03s9mG+9ns6e0EaKCqDOWf4sUJOHREvqciOn7Us0cEZiYmJhnc7HtVbJtS5LsVRo09DScZzmSG5iYmJit2RTVlduGquS920hFvxRMTEzMRzOv6TfKheMX9ThMTEzMnvlj5ld/S0xMTMxjNoGjc3pdi6L4AAAAAElFTkSuQmCC'))

    i = Magick::ImageList.new
    i.extend MemeCaptain::ImageList::Fetch
    i.fetch! 'http://memecaptain.com/good.jpg'

    i.columns.should == 460
    i.rows.should == 50
  end

  it 'should raise FetchError if the URL is not found' do
    i = Magick::ImageList.new
    i.extend MemeCaptain::ImageList::Fetch
    stub_request(:get, 'http://memecaptain.com/does_not_exist.jpg').to_return(
      :status => 404)
    expect {
      i.fetch! 'http://memecaptain.com/does_not_exist.jpg'
    }.to raise_error(MemeCaptain::ImageList::FetchError)
  end

end
