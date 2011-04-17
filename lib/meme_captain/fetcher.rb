require 'cgi'

module MemeCaptain

  class Fetcher

    def initialize(folder); @folder = folder; end

    def cached_path(url)
      File.join(folder, File.expand_path(CGI.escape(url), '/'))
    end

    def fetch(url)
      cp = cached_path(url)

      if File.exist?(cp)
        open(cp, 'rb') { |f| f.read }
      else
        data = Curl::Easy.perform(url).body_str
        open(cp, 'w') do |f|
          f.flock(File::LOCK_EX)
          f.write(data)
          f.flock(File::LOCK_UN)
        end
        data
      end
    end

    attr_reader :folder
  end

end
