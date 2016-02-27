require 'minitest/spec'
require 'minitest/autorun'
require 'naseweis/util'

describe 'test Naseweis::Util' do
  [
    ['', true],
    ['.', true],
    ['foobar', true],
    ['(', false],
    [')', false],
  ].each do |regex, expect|
    it "test valid_regex? with /#{regex}/" do
      assert_equal expect, Naseweis::Util.valid_regex?(regex)
    end
  end

  [
    ['1', 1],
    ['1.0', 1.0],
    [nil, nil],
  ].each do |input, result|
    it "test parse_num with '#{input}'" do
      actual = Naseweis::Util.parse_num input
      assert_instance_of result.class, actual
      assert_equal result, actual
    end
  end
end
