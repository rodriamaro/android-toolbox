# ------------------------------------------------------------------------------
# The Android Toolbox Rakefile
# ------------------------------------------------------------------------------

require 'rubygems'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "bin" << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end
