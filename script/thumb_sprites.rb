require 'json'
require 'RMagick'

# make a combined thumbnail image from a list of images for use in CSS sprites
# generate source images description json

url_prefix = 'http://memecaptain.com/'

data = {
  :thumbHeight => 50,
  :thumbSpritesUrl => "#{url_prefix}thumbs.jpg",
  :images => [],
}

thumbs = Magick::ImageList.new

ARGV.sort.each do |file|
  image = Magick::ImageList.new(file)
  image.resize_to_fit!(0, data[:thumbHeight])
  image.each do |frame|
    thumbs.push frame
    data[:images] << {
      :url => "#{url_prefix}#{File.basename(file)}",
      :thumbWidth => frame.columns
    }
  end
end

open('source_images.json', 'w') do |f|
  f.write(JSON.pretty_generate(data))
end

thumbs.append(false).write('thumbs.jpg')
