# frozen_string_literal: true

require 'test_plugin_helper'

module ForemanGitTemplates
  class SnippetRepositoryTest < ActiveSupport::TestCase
    let(:snippet_repository_template) { ForemanGitTemplates::SnippetRepositoryTemplate.new(name: 'CoreOS provision Ignition') }

    test '#path downcases the filename and replaces spaces with underscores' do
      assert_equal 'templates/snippets/coreos_provision_ignition.erb', snippet_repository_template.path
    end
  end
end
