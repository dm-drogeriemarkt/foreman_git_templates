# frozen_string_literal: true

require 'test_plugin_helper'

class RepositorySourceTest < ActiveSupport::TestCase
  let(:repo_path) { '/tmp/repository.tar.gz' }
  let(:template) { ForemanGitTemplates::MainRepositoryTemplate.new(name: 'MyTemplate') }
  let(:subject) { ForemanGitTemplates::Renderer::Source::Repository.new(template, repo_path) }

  describe '#content' do
    let(:content) { 'content' }

    test 'should return content' do
      ForemanGitTemplates::RepositoryReader.expects(:call).once.with(repo_path, template.path).returns(content)
      assert_equal content, subject.content
    end
  end

  describe '#find_snippet' do
    let(:snippet_name) { 'MySnippet' }
    let(:snippet) { subject.find_snippet(snippet_name) }

    test 'should return snippet template' do
      assert snippet.is_a?(ForemanGitTemplates::SnippetRepositoryTemplate)
      assert_respond_to snippet, :render
      assert_equal snippet_name, snippet.name
    end
  end
end
