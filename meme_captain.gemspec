# -*- encoding: utf-8 -*-

$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'meme_captain/version'

Gem::Specification.new do |s|
  s.name = 'meme_captain'
  s.version = MemeCaptain::VERSION
  s.summary = 'create meme images'
  s.description = s.summary
  s.homepage = 'https://github.com/mmb/meme_captain'
  s.authors = ['Matthew M. Boedicker']
  s.email = %w{matthewm@boedicker.org}
  s.license = 'MIT'

  s.add_dependency 'mime-types', '~> 2.5'
  s.add_dependency 'rmagick', '~> 2.15.3'

  s.add_development_dependency 'rake', '~> 10.4.2'
  s.add_development_dependency 'rspec', '~> 3.2.0'
  s.add_development_dependency 'webmock', '~> 1.21.0'

  s.files = `git ls-files`.split("\n")
  s.executables = %w{memecaptain}
end
