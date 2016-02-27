module Naseweis
  # Range objects are used to check whether a value is in the given range.
  #
  # Ranges are specified in the (mathematical) syntax +min < x < max+, where
  # x is the fixed variable name and +min+ and +max+ are the limits. If the
  # limits are included, you can use the +<=+ operator instead. If the range
  # is unlimited on one end, this side can be omitted.
  class Range
    float = /\d+(\.\d+)?/
    # The pattern that is used to match and extract data from the string
    # range description
    PATTERN = /(((#{float})\s*(<=?)\s*)?x\s*(<=?)\s*(#{float}))|
               ((#{float})\s*(<=?)\s*x)/x

    # Initialize the range.
    #
    # @param range [String] the string that describes the range as specified
    #   by the class description
    # @raise [ArgumentError] if the given string does not describe a valid
    #   range
    def initialize(range) # rubocop: disable Metrics/AbcSize
      match = PATTERN.match range
      raise ArgumentError, "invalid range: #{range}" if match.nil?
      captures = match.captures
      if captures[0].nil?
        # Dealing with "... < x" here
        @min = captures[9]
        @min_included = captures[11] == '<='
        @max = nil
        @max_included = nil
      else
        @min = captures[2]
        @min_included = captures[4]
        @min_included = @min_included == '<=' unless @min_included.nil?
        @max = captures[6]
        @max_included = captures[5] == '<='
      end
      @min = Util.parse_num @min
      @max = Util.parse_num @max
    end

    # Check if the given number lies within the range boundaries
    #
    # @param num [Numeric] the number to check
    # @return [Boolean] true if the number is within the range
    def include?(num)
      lower_include = (@min.nil? || (@min <= num && @min_included) ||
                       @min < num)
      upper_include = (@max.nil? || (@max >= num && @max_included) ||
                       @max > num)
      lower_include && upper_include
    end

    # Generate a string representation for this range
    #
    # The result can be fed back into {#new} to get the same range
    #
    # @return [String] the string representation
    def to_s
      result = ''
      unless @min.nil?
        result << @min.to_s << ' ' << (@min_included ? '<= ' : '< ')
      end
      result << 'x'
      unless @max.nil?
        result << (@max_included ? ' <= ' : ' < ') << @max.to_s
      end
      result
    end

    # Check whether ranges can be used with the given type
    #
    # @param type [String,Symbol] type to check
    # @return [Boolean] true if the type can be used with +range:+
    def self.ranged_type?(type)
      [:int, :integer, :float].include?(type.intern)
    end
  end
end
