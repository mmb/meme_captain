require 'RMagick'

module MemeCaptain

  module_function

  # Create a meme image.
  # Input can be an IO object or a blob of data.
  def meme(input, line1, line2, options={})
    img = Magick::ImageList.new
    if input.respond_to?(:read)
      img.from_blob(input.read)
    else
      img.from_blob(input)
    end

    options = {
      :fill => 'white',
      :font => 'Impact',
      :gravity => Magick::CenterGravity,
      :size => "#{img.page.width * 1.8}x#{img.page.height / 2}",
      :stroke => 'black',
      :stroke_width => 2,
      :background_color => 'none',
      }.merge(options)

    line1_caption = Magick::Image.read("caption:#{line1.to_s.upcase}") {
      options.each { |k,v| self.send("#{k}=", v) }
    }
    line1_caption[0].resize!(line1_caption[0].columns / 2,
      line1_caption[0].rows / 2, Magick::LanczosFilter, 1.25)

    line2_caption = Magick::Image.read("caption:#{line2.to_s.upcase}") {
      options.each { |k,v| self.send("#{k}=", v) }
    }
    line2_caption[0].resize!(line2_caption[0].columns / 2,
      line2_caption[0].rows / 2, Magick::LanczosFilter, 1.25)

    text_layer = Magick::Image.new(img.page.width, img.page.height) {
      self.background_color = 'none'
    }
    text_layer.composite!(line1_caption[0], Magick::NorthGravity,
      Magick::OverCompositeOp)
    text_layer.composite!(line2_caption[0], Magick::SouthGravity,
      Magick::OverCompositeOp)

    img.each do |frame|
      frame.composite!(text_layer, -frame.page.x, -frame.page.y,
        Magick::OverCompositeOp)
      frame.strip!
    end
    img

  end

end
