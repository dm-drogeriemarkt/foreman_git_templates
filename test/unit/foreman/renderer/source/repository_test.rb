# frozen_string_literal: true

require 'test_plugin_helper'

class RepositorySourceTest < ActiveSupport::TestCase
  setup do
    @template_url = 'http://template.pl'
    @template = ForemanGitTemplates::MainRepositoryTemplate.new(name: 'MyTemplate')
    @subject = ForemanGitTemplates::Renderer::Source::Repository.new(@template, @template_url)
  end

  describe '#content' do
    test 'should return content' do
      repo_path = '/tmp/repo.tar.gz'
      content = 'content'

      ForemanGitTemplates::RepositoryFetcher.expects(:call).once.with(@template_url).returns(repo_path)
      ForemanGitTemplates::RepositoryReader.expects(:call).once.with(repo_path, @template.path).returns(content)

      assert_equal content, @subject.content
    end
  end

  describe '#find_snippet' do
    test 'should return snippet template' do
      snippet_name = 'MySnippet'
      snippet = @subject.find_snippet(snippet_name)

      assert snippet.is_a?(ForemanGitTemplates::SnippetRepositoryTemplate)
      assert snippet.respond_to?(:render)
      assert_equal snippet_name, snippet.name
    end
  end
end
