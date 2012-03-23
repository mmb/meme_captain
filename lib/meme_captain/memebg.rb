require 'RMagick'

module MemeCaptain

  module_function

  # Public: Generate a pie slice meme background.
  #
  # size     - The side length in pixels of the generated image.
  # colors   - An Array of color strings (any values that RMagick accepts).
  # num_rays - The Fixnum of rays to create.
  # block    - An optiona block passed to Draw.new for specifying additional
  #            draw options
  # 
  # Examples
  # 
  #   memebg(400, %w{red orange yellow green blue indigo violet}, 20) {
  #     # draw options
  #     # self.stroke = 'white'
  #   }.display
  #
  # Returns a Magick::Image of the meme background.
  def memebg(size, colors, num_rays, &block)
    # make circle 5% too big to avoid empty space at corners from rounding
    # errors
    circle_radius = Math.sqrt(2 * ((size / 2.0) ** 2)) * 1.05

    side_len = 2 * circle_radius

    start_x = side_len
    start_y = circle_radius

    center = "#{circle_radius},#{circle_radius}"

    img = Magick::Image.new(side_len, side_len)

    color_cycle = colors.cycle

    (1..num_rays).each do |ray_index|
      ray_radius = 2 * Math::PI / num_rays * ray_index

      end_x = circle_radius + (Math.cos(ray_radius) * circle_radius)
      end_y = circle_radius - (Math.sin(ray_radius) * circle_radius)

      svg = "M#{center} L#{start_x},#{start_y} A#{center} 0 0,0 #{end_x},#{end_y} z"

      draw = Magick::Draw.new {
        instance_eval(&block)  if block_given?
        self.fill = color_cycle.next
      }

      draw.path svg
      draw.draw img

      start_x = end_x
      start_y = end_y
    end

    img.crop! Magick::CenterGravity, size, size
  end

end
