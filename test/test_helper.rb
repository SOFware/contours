# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter ["/test/", "/contours/version.rb"]
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "contours"

require "minitest/autorun"
