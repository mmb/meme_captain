# encoding: UTF-8

require 'RMagick'

module MemeCaptain

  # Text to put on an image with position and style options.
  class TextPos

    # x and y are the coordinates of the top left corner of the text
    # bounding rectangle.
    #
    # width and height are the width and height of the text bounding
    # rectangle.
    #
    # x, y, width and height can be in pixels or a float that represents a
    # percentage of the width and height of the image the text is put onto.
    def initialize(text, x, y, width, height, options = {})
      @text = text
      @x = x
      @y = y
      @width = width
      @height = height

      @max_lines = options.delete(:max_lines) || 16
      @min_pointsize = options.delete(:min_pointsize) || 12

      @draw_options = {
          fill: 'white',
          font: 'Impact',
          gravity: Magick::CenterGravity,
          stroke: 'black',
          stroke_width: 8,
      }.merge(options)
    end

    attr_accessor :text
    attr_accessor :x
    attr_accessor :y
    attr_accessor :width
    attr_accessor :height
    attr_accessor :max_lines
    attr_accessor :min_pointsize
    attr_accessor :draw_options
  end

end
