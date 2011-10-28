require 'RMagick'

# make a combined thumbnail image from a list of images for use in CSS sprites

puts 'images = ['

thumbs = Magick::ImageList.new

ARGV.sort.each do |file|
  image = Magick::ImageList.new(file)
  image.resize_to_fit!(0, 50)
  image.each do |frame|
    thumbs.push frame
    puts "  ['#{File.basename(file)}', #{frame.columns}],"
  end
end

puts ']'

thumbs.append(false).write('thumbs.jpg')
