# frozen_string_literal: true

# This calls the main test_helper in Foreman-core
require 'test_helper'

# Add plugin to FactoryBot's paths
FactoryBot.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryBot.reload

def stub_repository(template_url, repository_path)
  build_repository(repository_path) do |tar|
    yield tar if block_given?
  end
  stub_request(:get, template_url).to_return(status: 200, body: File.new(repository_path))
end

def build_repository(repository_path)
  ForemanGitTemplates::Tar.tar(repository_path) do |tar|
    yield tar if block_given?
  end
end
