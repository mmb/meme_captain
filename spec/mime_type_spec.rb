require 'meme_captain'

describe 'MemeCaptain.mime_type' do

  before do
    @gif1_data = ['474946383961'].pack('H12')
    @gif2_data = ['474946383761'].pack('H12')
    @jpeg_data = ['ffd8'].pack('H4')
    @png_data = ['89504e470d0a1a0a'].pack('H16')
  end

  it 'should detect a gif type 1 blob' do
    MemeCaptain.mime_type(@gif1_data).should == 'image/gif'
  end

  it 'should detect a gif type 2 blob' do
    MemeCaptain.mime_type(@gif2_data).should == 'image/gif'
  end

  it 'should detect a jpeg blob' do
    MemeCaptain.mime_type(@jpeg_data).should == 'image/jpeg'
  end

  it 'should detect a png blob' do
    MemeCaptain.mime_type(@png_data).should == 'image/png'
  end

end
