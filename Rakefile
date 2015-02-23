require 'rspec/core/rake_task'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new do |task|
  task.rspec_opts = '--color'
end

Cucumber::Rake::Task.new

task default: [:spec, :cucumber]
