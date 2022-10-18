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

namespace :foreman_git_templates do
  task rubocop: :environment do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_foreman_git_templates) do |task|
        task.patterns = ["#{ForemanGitTemplates::Engine.root}/app/**/*.rb",
                         "#{ForemanGitTemplates::Engine.root}/lib/**/*.rb",
                         "#{ForemanGitTemplates::Engine.root}/test/**/*.rb"]
      end
    rescue StandardError
      puts 'Rubocop not loaded.'
    end

    Rake::Task['rubocop_foreman_git_templates'].invoke
  end
end

Rake::Task[:test].enhance ['test:foreman_git_templates']

load 'tasks/jenkins.rake'
if Rake::Task.task_defined?(:'jenkins:unit')
  Rake::Task['jenkins:unit'].enhance ['test:foreman_git_templates',
                                      'foreman_git_templates:rubocop']
end
