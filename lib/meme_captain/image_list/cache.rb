require 'digest/sha1'
require 'fileutils'
require 'mime/types'

module MemeCaptain

  module ImageList

    # Mix-in for Magick::ImageList to add saving to the filesystem based on a
    # hash.
    module Cache

      # Get the extension for this image.
      def extension
        {
          'image/jpeg' => 'jpg',
        }[mime_type] || MIME::Types[mime_type][0].extensions[0]
      end

      # Store this image in the filesystem and return its path.
      def cache(hash_base, dir)
        hashe = Digest::SHA1.hexdigest(hash_base)

        cache_dir = File.join(dir, hashe[0,3])
        FileUtils.mkdir_p cache_dir

        file_part = hashe[3..-1]
        fs_path = File.join(cache_dir, "#{file_part}.#{extension}")

        # If there is a collision add 0's until the filename is unique.
        zeroes = 0
        while File.exist? fs_path
          zeroes += 1
          fs_path = File.join(cache_dir,
            "#{file_part}#{'0' * zeroes}.#{extension}")
        end

        write(fs_path) {
          self.quality = 100
        }

        fs_path
      end

    end

  end

end
