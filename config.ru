$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'meme_captain'

run MemeCaptain::Server
