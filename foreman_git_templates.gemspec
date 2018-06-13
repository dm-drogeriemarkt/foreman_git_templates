require File.expand_path('../lib/foreman_git_templates/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'foreman_git_templates'
  s.version     = ForemanGitTemplates::VERSION
  s.license     = 'GPL-3.0'
  s.authors     = ['dm-drogerie markt GmbH & Co. KG']
  s.email       = ['opensource@dm.de']
  s.homepage    = 'https://github.com/dm-drogeriemarkt-de/foreman_git_templates'
  s.summary     = 'Adds support for using templates from Git repositories'

  s.files = Dir['{app,config,db,lib,locale}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rdoc'
end
