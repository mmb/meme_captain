module MemeCaptain

  # A Rack body for an object on the filesystem.
  class FileBody

    def initialize(path); @to_path = path; end

    def each
      open(to_path, 'rb') { |f| yield f.read(8192) until f.eof? }
    end

    attr_reader :to_path
  end

end
