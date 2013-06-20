# encoding: UTF-8

module MemeCaptain

  class Caption < String

    def initialize(s = '')
      super s.to_s
    end

    # Return the contents of the string quoted for ImageMagick annotate.
    def annotate_quote
      Caption.new(gsub('\\', '\\\\\\').gsub('%', '\%'))
    end

    # Whether the string contains any non-whitespace.
    def drawable?
      match(/[^\s]/) ? true : false
    end

    # Wrap the string of into num_lines lines.
    def wrap(num_lines)
      cleaned = gsub(/\s+/, ' ').strip

      chars_per_line = cleaned.size / num_lines.to_f

      lines = []
      cleaned.split.each do |word|
        if lines.empty?
          lines << word
        else
          if (lines[-1].size + 1 + word.size) <= chars_per_line ||
              lines.size >= num_lines
            lines[-1] << ' ' unless lines[-1].empty?
            lines[-1] << word
          else
            lines << word
          end
        end
      end

      Caption.new(lines.join("\n"))
    end

  end

end
