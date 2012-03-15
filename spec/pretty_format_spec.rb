require 'meme_captain'

describe MemeCaptain, '.pretty_format' do

  it 'should format a hash like pp would' do
    MemeCaptain.pretty_format(:a => 1).should == "{:a=>1}\n"
  end

end
