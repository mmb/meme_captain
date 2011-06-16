module MemeCaptain

  # Cache data on filesystem.
  class FilesystemCache

    def initialize(root_dir); @root_dir = root_dir; end

    # Get the data of a file in the cache.
    #
    # On cache miss, if block given, call block to get data from source and
    # cache it. If no block given return nil on cache miss.
    #
    # If suffixes are passed in, loop through them and search for base id +
    # suffix on filesystem. Return the data of the first found.
    def get_data(id, suffixes=[''])
      suffixes.each do |suffix|
        file_path = id_path(id, suffix)
        return open(file_path, 'rb') { |f| f.read }  if File.exist?(file_path)
      end

      # not found in cache
      if block_given?
        data = yield
        put(id, data)
        data
      end
    end

    # Get the path of a file in the cache.
    #
    # On cache miss, if block given, call block to get data from source and
    # cache it. If no block given return nil on cache miss.
    #
    # If suffixes are passed in, loop through them and search for base id +
    # suffix on filesystem. Return the first found.
    def get_path(id, suffixes=[''])
      suffixes.each do |suffix|
        file_path = id_path(id, suffix)
        return file_path  if File.exist?(file_path)
      end

      # not found in cache
      put(id, yield)  if block_given?
    end

    # Put data in the cache and return its path.
    def put(id, data)
      mime_type = MemeCaptain.mime_type(data)
      unless mime_type
        raise 'Data loaded from source image url is not an image'
      end
      file_path = id_path(id, ".#{mime_type.extensions[0]}")

      open(file_path, 'w') do |f|
        f.flock(File::LOCK_EX)
        f.write(data)
        f.flock(File::LOCK_UN)
      end
      file_path
    end

    # Get the cache file path for an id with optional suffix added.
    def id_path(id, suffix=nil)
      File.join(root_dir, File.expand_path(id, '/')) + suffix.to_s
    end

    attr_reader :root_dir
  end

end
