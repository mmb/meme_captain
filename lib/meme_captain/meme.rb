require 'RMagick'

module MemeCaptain

  module_function

  # Create a meme image.
  #
  # Input can be an IO object or a blob of data. text_poss is an enumerable
  # of TextPos objects containing text, position and style options.
  #
  # Options:
  #   super_sample - work this many times larger before shrinking
  def meme(input, text_poss, options={})
    img = Magick::ImageList.new
    if input.respond_to?(:read)
      img.from_blob(input.read)
    else
      img.from_blob(input)
    end

    img.auto_orient!

    super_sample = options[:super_sample] || 1.0

    text_layer = Magick::Image.new(
      img.page.width * super_sample, img.page.height * super_sample) {
      self.background_color = 'none'
    }

    text_poss.each do |text_pos|
      caption = Caption.new(text_pos.text)

      if caption.drawable?
        wrap_tries = (1..text_pos.max_lines).map { |num_lines|
          caption.wrap(num_lines).upcase.annotate_quote
        }.uniq

        text_x = (text_pos.x.is_a?(Float) ?
          img.page.width * text_pos.x : text_pos.x) * super_sample

        text_y = (text_pos.y.is_a?(Float) ?
          img.page.height * text_pos.y : text_pos.y) * super_sample

        text_width = (text_pos.width.is_a?(Float) ?
          img.page.width * text_pos.width : text_pos.width) * super_sample

        text_height = (text_pos.height.is_a?(Float) ?
          img.page.height * text_pos.height : text_pos.height) * super_sample

        min_pointsize = text_pos.min_pointsize * super_sample

        draw = Magick::Draw.new.extend(Draw)

        text_pos.draw_options.each do |k,v|
          # options that need to be scaled by super sample
          if [
            :stroke_width
            ].include?(k)
            v *= super_sample
          end
          draw.send("#{k}=", v)
        end

        choices = wrap_tries.map do |wrap_try|
          pointsize, metrics = draw.calc_pointsize(text_width, text_height,
            wrap_try, min_pointsize)

          CaptionChoice.new(pointsize, metrics, wrap_try, text_width,
            text_height)
        end

        choice = choices.max

        draw.pointsize = choice.pointsize

        draw.annotate text_layer, text_width, text_height, text_x, text_y,
          choice.text

        text_layer.virtual_pixel_method = Magick::TransparentVirtualPixelMethod
        text_layer = text_layer.blur_channel(text_pos.draw_options[:stroke_width] / 2.0,
                                             text_pos.draw_options[:stroke_width] / 4.0, Magick::OpacityChannel)

        draw.stroke = 'none'

        draw.annotate text_layer, text_width, text_height, text_x, text_y,
          choice.text
      end
    end

    if super_sample != 1
      text_layer.resize!(1.0 / super_sample)
      text_layer = text_layer.unsharp_mask
    end

    img.each do |frame|
      frame.composite!(text_layer, -frame.page.x, -frame.page.y,
        Magick::OverCompositeOp)
      frame.strip!
    end

    text_layer.destroy!

    img
  end

  # Shortcut to generate a typical meme with text at the top and bottom.
  def meme_top_bottom(input, top_text, bottom_text, options={})
    meme(input, [
      TextPos.new(top_text, 0.05, 0, 0.9, 0.25, options),
      TextPos.new(bottom_text, 0.05, 0.75, 0.9, 0.25, options)
      ])
  end

end
