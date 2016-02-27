require 'naseweis/converter'
require 'naseweis/range'
require 'naseweis/version'
require 'naseweis/util'
require 'yaml'
require 'highline'

# The Naseweis module is a module which takes a +Weisheits+-file (or short
# +Weisfile+) and asks the user the questions that are defined in the
# +Weisfile+.
#
# This is useful if you have an application that needs to ask a lot of
# questions and you'd rather keep the questions (the data) out of the program
# (the logic).
#
# This module helps by defining a "mini-language", which can be used to specify
# questions and later retrieve their answers to process them.
#
# For more information about the file format see the +Weisfile+ document.
module Naseweis
  # Exception raised when the input file (+Weisheits+-file) is malformed
  class WeisheitError < StandardError
  end

  # A class to read a +Weisfile+ and gather user input
  #
  # @attr_reader [String] filename The path to the file which is used by this
  #   {Nase}
  # @attr_reader [Array] questions All questions handled by this {Nase}.
  #
  #   To update the questions, use the {#read} method.
  # @attr_reader [Converter] converter The converter that is used to convert
  #   types
  class Nase
    attr_reader :filename, :questions, :converter

    # Create a new {Nase} which reads questions from the given file
    #
    # @param path [String] path to the file with the questions
    def initialize(path)
      @filename = path
      @questions = {}
      @converter = Converter.new
    end

    # Update the questions and re-read them from the file that the Nase was
    # initialized with
    #
    # @return [void]
    # @raise [WeisheitError] if the input file is malformed
    def read
      questions = YAML.load_file(@filename)
      verify questions
      @questions = questions
    end

    # Check whether the given question is wellformed
    #
    # @param q [Hash,Array] the question or list of questions to check
    # @return [void]
    # @raise [WeisheitError] if the question is malformed
    def verify(q)
      if q.is_a? Array
        q.each { |x| verify x }
        return
      end
      type = q['type']
      validate = q['validate']
      qs = q['q']
      well = type.nil? || @converter.supported_types.include?(type.intern)
      raise WeisheitError, "invalid type #{type}" unless well
      well = validate.nil? || Util.valid_regex?(validate)
      raise WeisheitError, "invalid regex #{validate}" unless well
      verify qs if qs.is_a? Array
    end

    # Start the question session and return the user answers
    #
    # @param instream [File] input stream, i.e. stream where data is read from
    # @param outstream [File] output stream, i.e. stream where prompts are
    #   printed to
    # @return [Hash] Hash of the user answers, where the keys are defined by
    #   the question file.
    def interrogate(instream: $stdin, outstream: $stdout)
      @io = HighLine.new instream, outstream
      ask @questions
      @io = nil
    end

    private

    # Ask the given list of questions and return the answers as a Hash
    #
    # @param questions [Array] list of questions to ask
    # @return [Hash] Hash of the user answers
    def ask(questions)
      namespace = {}
      questions.each do |q|
        answer = do_question q
        namespace[q['target']] = answer if q.key?('target') && !answer.nil?
      end
      namespace
    end

    # Handle a single question and return the answer
    #
    # @param q [Hash] the question data
    # @return [String] for a simple question
    # @return [Array] for a repeating question
    def do_question(q)
      if q.key? 'desc'
        # Always output the description first
        @io.say q['desc']
      end

      repeat = q['repeat']
      return get_valid_input q if repeat.nil?
      return (1..repeat).collect { get_valid_input q } if repeat.is_a? Integer
      if repeat.is_a? String
        result = [get_valid_input(q)]
        result.push(get_valid_input(q)) while @io.agree repeat
      else
        result = []
        loop do
          line = get_valid_input q
          break if line.empty?
          result << line
        end
      end
      result
    end

    # Get a single line of user input that is valid for the given question
    #
    # @param q [Hash] the question which to get input for
    # @return [String] if the question is a simple question
    # @return [Hash] if the question has sub-questions
    # @return [Object] if the question is type-converted
    def get_valid_input(q) # rubocop: disable Metrics/AbcSize
      prompt = q['q']
      prompt = '' if prompt.nil?
      validate = q['validate']
      result = nil
      loop do
        if prompt.is_a? Array
          result = ask prompt
        elsif !q['choices'].nil?
          @io.say prompt
          result = @io.choose(*q['choices'])
        else
          result = @io.ask prompt
          if !validate.nil? && !result.match(validate)
            @io.say "invalid input, must match /#{validate}/"
            next
          end
        end

        break if q['type'].nil?

        begin
          result = @converter.convert result, q['type']
        rescue ConversionError
          @io.say "invalid value for type #{q['type']}"
          next
        end

        break if !Range.ranged_type?(q['type']) || q['range'].nil?
        range = Range.new q['range']
        break if range.include? result
        @io.say "value out of range (#{range})"
      end
      result
    end
  end
end
