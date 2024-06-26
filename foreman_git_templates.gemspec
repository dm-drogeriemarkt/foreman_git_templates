# frozen_string_literal: true

require File.expand_path('lib/foreman_git_templates/version', __dir__)

Gem::Specification.new do |s|
  s.name        = 'foreman_git_templates'
  s.version     = ForemanGitTemplates::VERSION
  s.license     = 'GPL-3.0'
  s.authors     = ['dmTECH GmbH']
  s.email       = ['opensource@dm.de']
  s.homepage    = 'https://github.com/dm-drogeriemarkt/foreman_git_templates'
  s.summary     = 'Adds support for using templates from Git repositories'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.required_ruby_version = '>= 2.5', '< 4'

  s.add_dependency 'rest-client', '~> 2'

  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'theforeman-rubocop', '~> 0.1.2'
end
