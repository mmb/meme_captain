require 'RMagick'

module MemeCaptain

  module_function

  def meme(path_or_io, line1, line2, options={})
    img = Magick::ImageList.new
    if path_or_io.respond_to?(:read)
      img.from_blob(path_or_io.read)
    else
      img.read(path_or_io)
    end

    options = {
      :fill => 'white',
      :font => 'Impact-Regular',
      :gravity => Magick::CenterGravity,
      :size => "#{img.columns}x#{img.rows / 4}",
      :stroke => 'black',
      :stroke_width => 1,
      :background_color => 'none',
      }.merge(options)

    line1_caption = Magick::Image.read("caption:#{line1.upcase}") {
      options.each { |k,v| self.send("#{k}=", v) }
    }

    line2_caption = Magick::Image.read("caption:#{line2.upcase}") {
      options.each { |k,v| self.send("#{k}=", v) }
    }

    img[0].composite!(line1_caption[0], Magick::NorthGravity,
      Magick::OverCompositeOp)

    img[0].composite!(line2_caption[0], Magick::SouthGravity,
      Magick::OverCompositeOp)
  end

end
