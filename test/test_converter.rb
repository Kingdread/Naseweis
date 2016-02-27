require 'minitest/spec'
require 'minitest/autorun'
require 'naseweis/converter'

describe Naseweis::Converter do
  before do
    @conv = Naseweis::Converter.new
  end

  [
    ['42', :int, 42],
    ['42', :float, 42.0],
    ['.', :regex, /./],
  ].each do |input, type, expected|
    it "convert '#{input}' to #{type}" do
      result = @conv.convert input, type
      assert_instance_of expected.class, result
      assert_equal expected, result
    end
  end

  [
    ['foo', :int],
    ['foo', :float],
    ['(', :regex],
  ].each do |input, type|
    it "rejects malformed #{type}: #{input}" do
      assert_raises Naseweis::ConversionError do
        @conv.convert input, type
      end
    end
  end
end
