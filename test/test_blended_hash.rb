# frozen_string_literal: true

require "test_helper"

class TestBlend < Contours::BlendedHash
  @blended_keys = %i[foo other more]
  def blend_foo(original, extras)
    [original, extras].flatten.compact.uniq.join(" ")
  end
end

class CustomWithObject
  def self.init(original)
    new(original)
  end

  def initialize(original)
    @original = original
  end

  def merge(extras)
    @original.merge(extras)
  end
end

module Contours
  class BlendedHashTest < Minitest::Test
    describe ".init" do
      it "returns the argument if it is a BlendedHash" do
        blended = BlendedHash.init({})
        expect(BlendedHash.init(blended)).must_equal(blended)
      end

      it "returns a BlendedHash if the argument is not a BlendedHash" do
        expect(BlendedHash.init({})).must_be_kind_of(BlendedHash)
      end
    end

    describe ".blend" do
      it "defines a custom blend method" do
        blend_method_name = TestBlend.blend(:something) do |original, new_value|
          [original, new_value]
        end
        expect(blend_method_name).must_equal(:blend_something)
        expect(TestBlend.new({}).blend_something("original", "new")).must_equal(["original", "new"])
      end

      it "defines a custom blend method using a with object" do
        blend_method_name = TestBlend.blend(:custom, with: CustomWithObject)
        expect(blend_method_name).must_equal(:blend_custom)
        expect(TestBlend.new({}).blend_custom({one: 1}, {two: 2})).must_equal({one: 1, two: 2})
      end
    end

    describe "#[]" do
      it "returns a BlendedHash if the value is a hash" do
        expect(BlendedHash.init({foo: {}})[:foo]).must_be_kind_of(BlendedHash)
      end

      it "returns the value if the value is not a hash" do
        expect(BlendedHash.init({foo: "bar"})[:foo]).must_equal("bar")
      end
    end

    describe "#fetch" do
      it "returns a BlendedHash if the value is a hash" do
        expect(BlendedHash.init({foo: {}}).fetch(:foo)).must_be_kind_of(BlendedHash)
      end

      it "returns the value if the value is not a hash" do
        expect(BlendedHash.init({foo: "bar"}).fetch(:foo)).must_equal("bar")
      end
    end

    describe "#dig" do
      it "returns a BlendedHash if the value is a hash" do
        expect(BlendedHash.init({foo: {}}).dig(:foo)).must_be_kind_of(BlendedHash)
      end

      it "returns the value if the value is not a hash" do
        expect(BlendedHash.init({foo: "bar"}).dig(:foo)).must_equal("bar")
      end
    end

    describe "#merge" do
      it "blends the values of the blended keys" do
        expect(TestBlend.new({foo: "bar"}).merge({foo: "baz"})[:foo]).must_equal("bar baz")
      end

      it "returns a BlendedHash" do
        expect(TestBlend.new({}).merge({foo: "baz"})).must_be_kind_of(BlendedHash)
      end

      it "blends the values of the blended keys recursively" do
        expect(TestBlend.new({one: {two: "baz"}}).merge({one: {two: "qux"}})[:one]).must_be_kind_of(BlendedHash)
      end

      it "blends arrays together" do
        expect(TestBlend.new({other: ["baz"]}).merge({other: ["qux"]})[:other]).must_equal(["baz", "qux"])
      end

      it "blends hashes together" do
        expect(TestBlend.new({other: {one: 1}}).merge({other: {two: 2}})[:other]).must_equal({one: 1, two: 2})
      end

      it "blends the values by overwriting" do
        expect(TestBlend.new({other: "baz"}).merge({other: "qux"})[:other]).must_equal("qux")
      end
    end

    describe "#to_hash" do
      it "returns a hash representation of simple objects" do
        blended = TestBlend.new({simple: "text", complex: {object: StructuredString.init("text").first("begin")}})
        expect(**blended).must_equal({simple: "text", complex: {object: "begin text"}})
      end

      it "recursively converts StructuredString values to String when using **" do
        structured = StructuredString.init("text").first("begin")
        blended = TestBlend.new({
          simple: "text",
          complex: {object: structured}
        })

        result = {**blended}
        expect(result[:simple]).must_equal("text")
        expect(result[:complex][:object]).must_equal("begin text")
        expect(result[:complex][:object]).must_be_kind_of(String)
        expect(result[:complex][:object]).wont_be_kind_of(Contours::StructuredString)
      end
    end

    describe "blending keys" do
      it "merges a BlendedHash with a hash" do
        start_blended = TestBlend.new({begin: "start"})
        blended = TestBlend.new({other: start_blended})
        expect(
          blended.merge({other: {adding: "more"}})
        ).must_equal(
          {other: {begin: "start", adding: "more"}}
        )
      end

      it "initializes a new BlendedHash when merging a hash with another" do
        blend_result = TestBlend.new({}).blend({start: "hash"}, {other: "hash"})
        expect(blend_result).must_be_kind_of(BlendedHash)
        expect(blend_result).must_equal({start: "hash", other: "hash"})
      end

      it "concatenate arrays" do
        blend_result = TestBlend.new({}).blend(["first"], ["second"])
        expect(blend_result).must_equal(["first", "second"])
      end

      it "returns the extra for other types of original values" do
        blend_result = TestBlend.new({}).blend("original", "extra")
        expect(blend_result).must_equal("extra")
      end
    end
  end
end
