require "Naseweis/version"
require "yaml"
require "highline"

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
  # A class to read a +Weisfile+ and gather user input
  #
  # @attr_reader [String] filename The path to the file which is used by this
  #   {Nase}
  # @attr_reader [Array] questions All questions handled by this {Nase}.
  #
  #   To update the questions, use the {#read} method.
  class Nase
    attr_reader :filename, :questions

    # Create a new {Nase} which reads questions from the given file
    #
    # @param path [String] path to the file with the questions
    def initialize(path)
      @filename = path
      @questions = {}
    end

    # Update the questions and re-read them from the file that the Nase was
    # initialized with
    #
    # @return [void]
    def read
      @questions = YAML.load_file(@filename)
    end

    # Start the question session and return the user answers
    #
    # @return [Hash] Hash of the user answers, where the keys are defined by
    #   the question file.
    def interrogate
      @io = HighLine.new
      ask @questions
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
        if q.key? "target" and answer != nil then
          namespace[q["target"]] = answer
        end
      end
      namespace
    end

    # Handle a single question and return the answer
    #
    # @param q [Hash] the question data
    # @return [String] for a simple question
    # @return [Array] for a repeating question
    def do_question(q)
      if q.key? "desc" then
        # Always output the description first
        @io.say q["desc"]
      end

      repeat = q["repeat"]
      if repeat == nil then
        return get_valid_input q
      elsif repeat.is_a? Integer then
        return (1..repeat).collect { get_valid_input q }
      elsif repeat.is_a? String then
        result = [get_valid_input(q)]
        while @io.agree repeat do
          result.push(get_valid_input(q))
        end
        return result
      else
        result = []
        while true do
          line = get_valid_input q
          break if line.empty?
          result << line
        end
        return result
      end
    end

    # Get a single line of user input that is valid for the given question
    #
    # @param q [Hash] the question which to get input for
    # @return [String] if the question is a simple question
    # @return [Hash] if the question has sub-questions
    # @return [Object] if the question is type-converted
    def get_valid_input(q)
      prompt = q["q"]
      prompt = prompt == nil ? "" : prompt
      while true do
        result = if prompt.is_a? Array then
          ask prompt
        elsif q["choices"] != nil then
          @io.say prompt
          @io.choose *q["choices"]
        else
          @io.ask prompt
        end
        if q["type"] != nil then
          begin
            result = convert result, q["type"]
          rescue ArgumentError
            @io.say "invalid value for type#{q["type"]}"
          else
            break
          end
        else
          # Break immediately if we don't need a typecheck
          break
        end
      end
      result
    end

    # Convert the data to the given target type
    #
    # @param data [String] the question answer
    # @param target [String] the target type
    # @return [Object] the converted data
    # @raise [ArgumentError] if the data cannot be converted to the given
    #   target
    def convert(data, target)
      types = {
        :int => :Integer,
        :integer => :Integer,
      }
      method(types[target.intern]).call(data)
    end
  end
end
