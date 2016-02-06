require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

namespace :test do
  desc 'Run all tests'
  task :all do
    Rake::Task['rubocop'].invoke
    Rake::Task['spec'].invoke
  end
end

task default: 'test:all'
