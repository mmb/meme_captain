module MemeCaptain

  # Normalize query string parameters.
  #
  # Provide defaults, do some basic validation and convert some parameters
  # to floats or integers.
  class NormParams

    def initialize(params={})
      @u = ''
      
      @t1 = ''
      @t2 = ''

      @t1x = 0.05
      @t1y = 0
      @t1w = 0.9
      @t1h = 0.25

      @t2x = 0.05
      @t2y = 0.75
      @t2w = 0.9
      @t2h = 0.25

      load params
    end

    # Load query string parameters.
    #
    # Do some basic validation and convert some parameters to floats or
    # integers.
    def load(params)
      params.select { |k,v|
        [
         :u,
         :t1,
         :t2,
        ].include? k.to_sym }.each do |k,v|
          send "#{k}=", v.to_s
        end

      params.select { |k,v|
        [
         :t1x,
         :t1y,
         :t1w,
         :t1h,

         :t2x,
         :t2y,
         :t2w,
         :t2h,
        ].include?(k.to_sym) and !v.to_s.empty? }.each do |k,v|
          send "#{k}=", convert_metric(v)
        end
    end

    # Return a sorted string representation of the fields.
    def signature
      instance_variables.sort.map { |v|
        name = v[1..-1] # remove @
        "#{name}#{instance_variable_get(v)}"
      }.join
    end

    attr_accessor :u

    attr_accessor :t1
    attr_accessor :t2

    attr_accessor :t1x
    attr_accessor :t1y
    attr_accessor :t1w
    attr_accessor :t1h

    attr_accessor :t2x
    attr_accessor :t2y
    attr_accessor :t2w
    attr_accessor :t2h

    private

    # Convert a metric string to a float or integer.
    #
    # Expects a string.
    def convert_metric(metric)
      metric.index('.') ? metric.to_f : metric.to_i
    end

  end

end
