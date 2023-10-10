# frozen_string_literal: true

require_relative "test_helper"

module Contours
  class TestStructuredString < Minitest::Test
    describe ".init" do
      it "returns the argument if it is a StructuredString" do
        existing = StructuredString.new("foo")
        expect(
          StructuredString.init(existing)
        ).must_equal(existing)
      end

      it "creates a new StructuredString if the argument is not a StructuredString" do
        expect(StructuredString.init("foo")).must_be_kind_of(StructuredString)
      end
    end

    describe "#to_s" do
      it "combines the parts of the string" do
        structured = StructuredString.new("base-string")
        structured.first("first")
        structured.last("last")
        structured << "other"
        structured.first("more-first")
        structured.last("more-last")
        structured << "middle"
        expect(structured.to_s).must_equal("first more-first base-string other middle last more-last")
      end
    end

    describe "#to_str" do
      it "acts as a string" do
        structured = StructuredString.new("base-string")
        structured.first("first")
        structured.last("last")
        structured << "other"
        structured.first("more-first")
        structured.last("more-last")
        structured << "middle"
        expect("The string is: " + structured).must_equal(
          "The string is: first more-first base-string other middle last more-last"
        )
      end
    end

    describe "#read" do
      it "returns the value of a named portion of the string" do
        structured = StructuredString.new("base-string")
        structured.first("first")
        structured.last("last")
        structured << "other"
        structured.first("more-first")
        structured.last("more-last")
        structured << "middle"
        expect(structured.read(:first)).must_equal(["first", "more-first"])
        expect(structured.read(:last)).must_equal(["last", "more-last"])
        expect(structured.read(:other)).must_equal(["other", "middle"])
        expect(structured.read(:base)).must_equal(["base-string"])
      end

      it "raises an error with an unknown named portion" do
        structured = StructuredString.new("base-string")
        expect do
          structured.read(:unknown)
        end.must_raise(ArgumentError)
      end
    end

    describe "#merge" do
      it "combines the values of a given StructuredString to itself" do
        original = StructuredString
          .new("base-string")
          .first("first")
          .last("last") << "other"
        merger = StructuredString
          .new("base-merger")
          .first("merger-first")
          .last("merger-last") << "merger-other"
        expect(
          original.merge(merger).to_s
        ).must_equal("first merger-first base-string base-merger other merger-other last merger-last")
      end

      it "appends a string to the middle of the string" do
        structured = StructuredString.new("base-string")
        structured.merge("other")
        expect(structured.to_s).must_equal("base-string other")
      end

      it "inserts a string according to a named method" do
        structured = StructuredString.new("base-string")
        structured.merge(["other", :first])
        expect(structured.to_s).must_equal("other base-string")
        structured.merge(["end", :last])
        expect(structured.to_s).must_equal("other base-string end")
      end

      it "raises an error with a named method that does not add to the string" do
        structured = StructuredString.new("base-string")
        expect do
          structured.merge(["other", :to_s])
        end.must_raise(ArgumentError)
      end

      it "raises an error with and unkown named method" do
        structured = StructuredString.new("base-string")
        expect do
          structured.merge(["other", :unknown])
        end.must_raise(NameError)
      end

      it "raises an error with other inputs" do
        expect do
          StructuredString.new("base-string").merge(1)
        end.must_raise(ArgumentError)
        expect do
          StructuredString.new("base-string").merge(:oops)
        end.must_raise(ArgumentError)
        expect do
          StructuredString.new("base-string").merge(["many", "strings", "here"])
        end.must_raise(ArgumentError)
      end
    end
  end
end
