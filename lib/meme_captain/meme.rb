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
      :size => "#{img.columns * 0.9}x#{img.rows / 4}",
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

    img.each do |frame|
      frame.composite!(line1_caption[0], Magick::NorthGravity,
        Magick::OverCompositeOp).strip!

      frame.composite!(line2_caption[0], Magick::SouthGravity,
        Magick::OverCompositeOp).strip!
    end
    img

  end

end
