# frozen_string_literal: true

require "delegate"

module Contours
  # BlendedHash is a utility class that allows you to merge two hashes.
  # It may be used to specify how to combine values that are specified
  # more than once. For example, if you have a BlendedHash like this:
  #
  #   class CssConfig < BlendedHash
  #     @blended_keys = %i[class]
  #     def blend_class(original, extras)
  #       [original, extras].flatten.compact.uniq.join(" ")
  #     end
  #   end
  #
  #   CssConfig.new({class: "foo"})
  #
  # And you merge it with another hash like this:
  #
  #   CssConfig.new({class: "foo"}).merge({class: "bar"})
  #
  # The result will be:
  #   {
  #     class: "foo bar"
  #   }
  #
  # See the source of this #{name} class for more details.
  class BlendedHash < DelegateClass(Hash)
    alias_method :to_hash, :__getobj__

    # Ensure that the initial hash is a BlendedHash
    def self.init(initial_hash)
      if initial_hash.is_a?(BlendedHash)
        initial_hash
      else
        new({}).merge(initial_hash)
      end
    end

    # Define a method that will be used to blend the value of a key.
    # The method name will be "blend_#{key}".
    # If a block is given, it will be used as the implementation of the method.
    # Otherwise, the default implementation will be used where the value of the
    # with argument is expected to receive 'init' with the original value and
    # then 'merge' with the extras value.
    def self.blend(key, with: nil, &block)
      if block
        define_method("blend_#{key}", &block)
      else
        define_method("blend_#{key}") do |original, extras|
          with.init(original).merge(extras)
        end
      end
    end

    # Recursively check for keys that are specified as blended and apply
    # the blend method to them or execute the blend_#{key} method if it exists
    # to set the new value.
    def merge(overrides)
      return self if overrides.nil? || overrides.empty?
      self.class.new(overrides.each_with_object(to_hash.dup) do |(key, value), hash|
        hash[key] = if blended_keys.include?(key)
          if respond_to?("blend_#{key}")
            send("blend_#{key}", hash[key], value)
          else
            blend(hash[key], value)
          end
        else
          value
        end
        hash
      end)
    end

    # Ensure that the return value of these methods is a BlendedHash
    def [](...)
      if super.is_a?(Hash)
        self.class.init(super)
      else
        super
      end
    end

    def fetch(...)
      if super.is_a?(Hash)
        self.class.init(super)
      else
        super
      end
    end

    def dig(...)
      if super.is_a?(Hash)
        self.class.init(super)
      else
        super
      end
    end

    # The keys that should be blended when merging two hashes.
    # Specify this in subclasses to customize the behavior.
    @blended_keys = []
    class << self
      attr_reader :blended_keys
    end
    def blended_keys = self.class.blended_keys

    # Default implementation of the blend method. Override this in subclasses
    # with a custom blend_#{key} method to customize the blending behavior for a
    # specific key.
    #

    def blend(original, extra)
      case original
      when BlendedHash, Hash
        self.class.init(original).merge(extra)
      when Array
        [original, extra].flatten.compact.uniq
      else
        extra
      end
    end
  end
end
