require 'RMagick'

module MemeCaptain

  module_function

  # Create a meme image.
  #
  # Input can be an IO object or a blob of data.
  #
  # Options:
  #   max_lines - maximum number of text lines per caption
  #   min_pointsize - minimum point size
  #   super_sample - work this many times larger before shrinking
  #   text_height_pct - float percentage of image height for each caption
  #   text_width_pct - float percentage of image width for each caption
  #
  #  Any other options will be set on the Draw objects for the text and
  #  can be used to control text fill, stroke, etc. See RMagick annotate
  #  attributes.
  def meme(input, top_text, bottom_text, options={})
    img = Magick::ImageList.new
    if input.respond_to?(:read)
      img.from_blob(input.read)
    else
      img.from_blob(input)
    end

    options = {
      :max_lines       => 16,
      :min_pointsize   => 12,
      :super_sample    => 2.0,
      :text_height_pct => 0.25,
      :text_width_pct  => 0.9,

      # Draw options
      :fill            => 'white',
      :font            => 'Impact',
      :stroke          => 'black',
      :stroke_width    => 8,
    }.merge(options)

    max_lines = options.delete(:max_lines)
    super_sample = options.delete(:super_sample)
    min_pointsize = options.delete(:min_pointsize) * super_sample

    text_width = img.page.width * options.delete(:text_width_pct) * super_sample
    text_height = img.page.height * options.delete(:text_height_pct) *
      super_sample

    text_layer = Magick::Image.new(
      img.page.width * super_sample, img.page.height * super_sample) {
      self.background_color = 'none'
      self.density = 72.0 * super_sample
    }

    draw = Magick::Draw.new {
      options.each { |k,v| self.send("#{k}=", v) }
    }

    draw.extend(Draw)

    [
      [Caption.new(top_text), Magick::NorthGravity],
      [Caption.new(bottom_text), Magick::SouthGravity],
    ].select { |x| x[0].drawable? }.each do |caption, gravity|
      wrap_tries = (1..max_lines).map { |num_lines|
        caption.wrap(num_lines).upcase.annotate_quote
      }.uniq

      choices = wrap_tries.map do |wrap_try|
        pointsize, metrics = draw.calc_pointsize(
          text_width, text_height, wrap_try, min_pointsize)

        CaptionChoice.new(pointsize, metrics, wrap_try, text_width,
          text_height)
      end

      choice = choices.max

      draw.gravity = gravity
      draw.pointsize = choice.pointsize

      draw.stroke = options[:stroke]
      draw.annotate text_layer, 0, 0, 0, 0, choice.text

      draw.stroke = 'none'
      draw.annotate text_layer, 0, 0, 0, 0, choice.text
    end

    text_layer.resize!(1.0 / super_sample)

    img.each do |frame|
      frame.composite!(text_layer, -frame.page.x, -frame.page.y,
        Magick::OverCompositeOp)
      frame.strip!
    end
    img

  end

end
