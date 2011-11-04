module MemeCaptain

  module_function

  # Wrap a string of text into num_lines lines.
  def word_wrap(s, num_lines)
    chars_per_line = s.size / num_lines.to_f

    lines = []
    s.split.each do |word|
      if lines.empty?
        lines << word
      else
        if (lines[-1].size + 1 + word.size) <= chars_per_line or
          lines.size >= num_lines
          lines[-1] << ' '  unless lines[-1].empty?
          lines[-1] << word
        else
          lines << word
        end
      end
    end

    lines.join "\n"
  end

end
