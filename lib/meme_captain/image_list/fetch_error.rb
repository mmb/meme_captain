module MemeCaptain

  module ImageList

    # Error for source image fetch failures.
    class FetchError < StandardError

      def initialize(response_code)
        @response_code = response_code
      end

      attr_accessor :response_code    
    end

  end

end
