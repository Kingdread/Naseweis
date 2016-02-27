module Naseweis
  # Various utility functions
  module Util
    # Check whether the given string is a valid regex
    #
    # @param regex [String] the string to check
    # @return [Boolean] true if it is a valid (well-formed) regex, false
    #   otherwise
    def self.valid_regex?(regex)
      begin
        Regexp.new regex
      rescue RegexpError
        return false
      end
      true
    end

    # Parse the given string into a number.
    #
    # The number is parsed as a float if it includes a dot, otherwise it is
    # parsed as integer. If +nil+ is passed, +nil+ is returned.
    #
    # @param num [String] the number string to convert
    # @return [Float] if the given string represents a float
    # @return [Integer] if the given string represents an integer
    # @return [NilClass] if the input was +nil+
    def self.parse_num(num)
      return nil if num.nil?
      return Float num if num.include? '.'
      Integer num
    end
  end
end
