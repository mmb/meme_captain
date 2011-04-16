require 'RMagick'

module MemeCaptain

  module_function

  def meme(input, line1, line2, options={})
    img = Magick::ImageList.new
    if input.respond_to?(:read)
      img.from_blob(input.read)
    elif File.readable?(input)
      img.read(input)
    else
      img.from_blob(input)
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
