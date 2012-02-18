#!/usr/bin/env ruby

# make a combined thumbnail image from a list of images for use in CSS sprites
# generate source images description json

require 'json'
require 'optparse'

require 'RMagick'

OPTIONS = {
  :json_file => 'source_images.json',
  :source_url_prefix => '',
  :thumb_file => "thumbs_#{Time.now.to_i}.jpg",
  :thumb_height => 50,
  :url_root => 'http://memecaptain.com/',
}

OptionParser.new do |opts|
  opts.banner = 'usage: thumb_sprites.rb [options] FILE...'

  opts.on('-j', '--json-file JSON_FILE', 'output JSON file path') do |j|
    OPTIONS[:json_file] = j
  end

  opts.on('-s', '--source-url-prefix SOURCE_URL_PREFIX',
    'source image URL prefix') do |s|
    OPTIONS[:source_url_prefix] = s
  end

  opts.on('-t', '--thumb-height THUMB_HEIGHT',
    'thumbnail height in pixels') do |t|
    OPTIONS[:thumb_height] = t
  end

  opts.on('-u', '--url-root URL_ROOT', 'URL root') do |u|
    OPTIONS[:url_root] = u
  end
end.parse!

DATA = {
  :thumbHeight => OPTIONS[:thumb_height],
  :thumbSpritesUrl => "#{OPTIONS[:url_root]}#{OPTIONS[:thumb_file]}",
  :images => [],
}

puts <<eos
source URL prefix: #{OPTIONS[:source_url_prefix]}
thumbnail height: #{OPTIONS[:thumb_height]}
URL root: #{OPTIONS[:url_root]}

eos

THUMBS = Magick::ImageList.new

ARGV.sort.each do |file|
  puts " processing #{file}"
  image = Magick::ImageList.new(file)
  image.resize_to_fit!(0, DATA[:thumbHeight])
  image.each do |frame|
    THUMBS.push frame
    DATA[:images] << {
      :url =>
        "#{OPTIONS[:url_root]}#{OPTIONS[:source_url_prefix]}#{File.basename(file)}",
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
