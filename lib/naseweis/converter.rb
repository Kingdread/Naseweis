module Naseweis
  # A +ConversionError+ is raised when the given data can't be converted to the
  # requested type. It acts as a common error to catch all other errors that
  # are raised by Ruby when converting between types.
  #
  # @attr_reader [String] data the data that was attempted to convert
  # @attr_reader [String] type the typename that was requested
  class ConversionError < StandardError
    attr_reader :data, :type

    # Create a new ConversionError
    #
    # @param data [String] value for {#data}
    # @param type [String] value for {#type}
    def initialize(data, type)
      @data = data
      @type = type
    end

    # Get the string representation for the error
    #
    # @return [String] error string
    def to_s
      "Can't convert '#{@data}' to #{type}"
    end
  end

  # The +Converter+ class provides a way to convert between stringy data and
  # native Ruby types. It's used to handle the +type:+ attribute of questions.
  #
  # @attr_reader [Hash] converters A hash of all available types.
  class Converter
    attr_reader :converters

    def initialize
      @converters = {
        int: ->(x) { Integer x },
        integer: ->(x) { Integer x },
        regex: ->(x) { Regexp.new x },
        regexp: ->(x) { Regexp.new x },
        float: ->(x) { Float x },
      }
    end

    # Convert the data to the given target type
    #
    # @param data [String] the question answer
    # @param type [String] the target type
    # @return [Object] the converted data
    # @raise [ConversionError] if the data cannot be converted to the given
    #   target
    def convert(data, type)
      type = type.intern
      raise ArgumentError, "Invalid type #{type}" unless @converters.key? type
      begin
        @converters[type][data]
      rescue
        raise ConversionError.new data, type
      end
    end

    # Get a list of all supported types
    #
    # @return [Array] an array of supported types
    def supported_types
      @converters.keys
    end
  end
end
