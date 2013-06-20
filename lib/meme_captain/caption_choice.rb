# encoding: UTF-8

module MemeCaptain

  # For comparing different caption line break and pointsize choices.
  class CaptionChoice
    include Comparable

    def initialize(pointsize, metrics, text, bound_width, bound_height)
      @pointsize = pointsize
      @metrics = metrics
      @text = text
      @bound_width = bound_width
      @bound_height = bound_height
    end

    def num_lines
      text.count("\n") + 1
    end

    def fits
      metrics.width <= bound_width && metrics.height <= bound_height
    end

    def fits_i
      fits ? 1 : 0
    end

    def <=>(other)
      [fits_i, pointsize, fits ? -num_lines : num_lines] <=>
        [other.fits_i, other.pointsize,
        other.fits ? -other.num_lines : other.num_lines]
    end

    attr_accessor :pointsize
    attr_accessor :metrics
    attr_accessor :text
    attr_accessor :bound_width
    attr_accessor :bound_height
  end

end
