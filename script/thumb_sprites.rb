#!/usr/bin/env ruby

# make a combined thumbnail image from a list of images for use in CSS sprites
# generate source images description json

require 'json'
require 'optparse'

require 'RMagick'

OPTIONS = {
  :url_prefix => 'http://memecaptain.com/',
  :thumb_height => 50,
  :thumb_file => "thumbs_#{Time.now.to_i}.jpg",
  :json_file => 'source_images.json',
}

OptionParser.new do |opts|
  opts.banner = 'usage: thumb_sprites.rb [options] FILE...'

  opts.on('-j', '--json-file JSON_FILE', 'output JSON file path') do |j|
    OPTIONS[:json_file] = j
  end

  opts.on('-t', '--thumb-height THUMB_HEIGHT',
    'thumbnail height in pixels') do |t|
    OPTIONS[:thumb_height] = t
  end

  opts.on('-u', '--url-prefix URL_PREFIX', 'URL prefix') do |u|
    OPTIONS[:url_prefix] = u
  end
end.parse!

DATA = {
  :thumbHeight => OPTIONS[:thumb_height],
  :thumbSpritesUrl => "#{OPTIONS[:url_prefix]}#{OPTIONS[:thumb_file]}",
  :images => [],
}

puts <<eos
thumbnail height: #{OPTIONS[:thumb_height]}
URL prefix: #{OPTIONS[:url_prefix]}

eos

THUMBS = Magick::ImageList.new

ARGV.sort.each do |file|
  puts " processing #{file}"
  image = Magick::ImageList.new(file)
  image.resize_to_fit!(0, DATA[:thumbHeight])
  image.each do |frame|
    THUMBS.push frame
    DATA[:images] << {
      :url => "#{OPTIONS[:url_prefix]}#{File.basename(file)}",
      :thumbWidth => frame.columns
    }
  end
end

open(OPTIONS[:json_file], 'w') do |f|
  f.write(JSON.pretty_generate(DATA))
  puts "wrote #{OPTIONS[:json_file]}"
end

THUMBS.append(false).write(OPTIONS[:thumb_file])
puts "wrote #{OPTIONS[:thumb_file]}"
