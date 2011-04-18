module MemeCaptain

  # Cache data on filesystem.
  class FilesystemCache

    def initialize(root_dir); @root_dir = root_dir; end

    # Get data from cache.
    #
    # On cache miss, if block given call block to get data from source and
    # cache it. If no block given return nil on cache miss.
    def get(id)
      file_path = id_path(id)

      if File.exist?(file_path)
        open(file_path, 'rb') { |f| f.read }
      else
        put(id, yield)  if block_given?
      end
    end

    # Put data in the cache and return it.
    def put(id, data)
      open(id_path(id), 'w') do |f|
        f.flock(File::LOCK_EX)
        f.write(data)
        f.flock(File::LOCK_UN)
      end
      data
    end

    def id_path(id)
      File.join(root_dir, File.expand_path(id, '/'))
    end

    attr_reader :root_dir
  end

end
