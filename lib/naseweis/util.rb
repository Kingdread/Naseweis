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
  end
end
