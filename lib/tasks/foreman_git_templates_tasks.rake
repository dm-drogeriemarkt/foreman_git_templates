# frozen_string_literal: true

require 'rake/testtask'

# Tests
namespace :test do
  desc 'Test ForemanGitTemplates'
  Rake::TestTask.new(:foreman_git_templates) do |t|
    test_dir = File.join(ForemanGitTemplates::Engine.root, 'test')
    t.libs << ['test', test_dir]
    t.pattern = File.join(test_dir, '**', '*_test.rb')
    t.verbose = true
    t.warning = false
  end
end

Rake::Task[:test].enhance ['test:foreman_git_templates']

load 'tasks/jenkins.rake'
Rake::Task['jenkins:unit'].enhance ['test:foreman_git_templates'] if Rake::Task.task_defined?(:'jenkins:unit')
