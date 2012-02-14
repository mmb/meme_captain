require 'pp'

module MemeCaptain

  module_function

  # Format an object like pp would would and return the formatted string.
  def pretty_format(o)
    PP.pp o, dump = ''
  end

end
