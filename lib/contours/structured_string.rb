# frozen_string_literal: true

module Contours
  # This class represents a string which has a particular order to its content.
  # The intended use is for setting up CSS class values for HTML.
  #
  # An element may required that the first part of a class be a particular value
  # and that the last part of a class be a particular value. For example, a
  # field with an error might have a class like this:
  #
  #   "input my-special-class input-error"
  #
  # Setting that up with a StructuredString would look like this:
  #
  #   config = StructuredString.new("input").last("input-error")
  #   config << "my-special-class"
  #   config.to_s #=> "input my-special-class input-error"
  #
  class StructuredString < DelegateClass(String)
    # Ensure that the argument string is a StructuredString
    def self.init(base)
      if base.is_a?(StructuredString)
        base
      else
        new(base)
      end
    end

    # Initialize with base string that is used to build the StructuredString
    # Other values will be added to the string in the order they are added.
    def initialize(base = "", separator: " ")
      @base = [base]
      @separator = separator
      @first = []
      @last = []
      @other = []
    end

    # Add a value to the beginning of the string
    def first(value)
      @first << value.to_s
      __setobj__ to_s
      self
    end

    # Add a value to the end of the string
    def last(value)
      @last << value.to_s
      __setobj__ to_s
      self
    end

    # Add a value to the middle of the string
    def <<(other)
      @other << other.to_s
      __setobj__ to_s
      self
    end

    # Read a particular portion of the structured string or raise an error
    def read(key)
      case key
      when :first
        @first
      when :base
        @base
      when :other
        @other
      when :last
        @last
      else
        raise ArgumentError, "Unknown accessor: #{key.inspect}"
      end
    end

    # Add a value to the string in a particular position
    # The argument must be a string or a 2 element array
    # If it is a 2 element array, the first element must be a string and the
    # second element must the name of a method used to merge the string to the
    # StructuredString.
    #
    # For example:
    #
    #   config = StructuredString.new("input")
    #   config.merge("my-special-class")
    #   config.merge(["input-error", :last])
    #   config.to_s #=> "input my-special-class input-error"
    #
    def merge(data)
      case data
      in StructuredString
        @first += data.read :first
        @base += data.read :base
        @other += data.read :other
        @last += data.read :last
      in [String, Symbol]
        if method(data.last)&.arity == 1
          send(data.last, data.first)
        else
          raise ArgumentError, %(Tried to use '#{data.last}' with "#{data.first}" but it doesn't take 1 argument)
        end
      in String
        send(:<<, data)
      else
        raise ArgumentError, "Must be a string or a 2 element array got: #{data.inspect}"
      end

      self
    end

    # Return the string representation of the StructuredString
    def to_s
      [@first, @base, @other, @last]
        .flatten
        .compact
        .map(&:to_s)
        .reject(&:empty?)
        .join(@separator)
    end
    alias_method :to_str, :to_s
    alias_method :inspect, :to_s

    def as_json(*)
      to_s
    end

    def to_json(*)
      to_s.to_json
    end

    def ==(other)
      to_s == other.to_s
    end
  end
end
