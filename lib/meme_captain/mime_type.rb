require 'mime/types'

module MemeCaptain

  module_function

  # Determine mime type from blob of image data.
  def mime_type(img_data)
    mime_type_s = if img_data[0,2].unpack('H4')[0] == 'ffd8'
      'image/jpeg'
    elsif img_data[0,8].unpack('H16')[0] == '89504e470d0a1a0a'
      'image/png'
    elsif %w{474946383961 474946383761}.include?(img_data[0,6].unpack('H12')[0])
      'image/gif'
    end

    MIME::Types[mime_type_s][0]
  end

end
