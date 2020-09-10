require 'rake'
require 'cucumber'
require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "--publish-quiet --format progress --tags 'not @wip'"
end

desc "Run Tests"
task :test => :features
