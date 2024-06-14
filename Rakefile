# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.warning = true
  t.test_files = FileList["test/**/test_*.rb"]
end

task default: :test

require "reissue/gem"

Reissue::Task.create do |t|
  t.version_file = "lib/contours/version.rb"
  t.version_limit = 3
end
