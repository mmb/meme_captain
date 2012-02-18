# -*- encoding: utf-8 -*-

$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'meme_captain/version'

Gem::Specification.new do |s|
  s.name = 'meme_captain'
  s.version = '0.0.6'
  s.version = MemeCaptain::VERSION
  s.summary = 'create meme images'
  s.description = s.summary
  s.homepage = 'https://github.com/mmb/meme_captain'
  s.authors = ['Matthew M. Boedicker']
  s.email = %w{matthewm@boedicker.org}

  %w{
    bson_ext
    curb
    json
    mime-types
    mongo
    mongo_mapper
    rack
    rack-contrib
    rack-rewrite
    rmagick
    sinatra
    }.each { |g| s.add_dependency g }

  %w{
    rspec
    webmock
    }.each { |g| s.add_development_dependency g }

  s.files = `git ls-files`.split("\n")
  s.executables = %w{memecaptain}
end
