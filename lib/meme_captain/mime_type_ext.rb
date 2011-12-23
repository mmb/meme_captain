require 'mime/types'

module MemeCaptain

  module_function

  # Get the file extension for a MIME type.
  def mime_type_ext(mime_type)
    {
      'image/jpeg' => 'jpg',
    }[mime_type] || MIME::Types[mime_type][0].extensions[0]
  end

end
