# frozen_string_literal: true

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'app'
  t.test_files = FileList['test/**/test_*.rb']
end

task default: :test
