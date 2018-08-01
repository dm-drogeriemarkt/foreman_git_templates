# frozen_string_literal: true

require 'test_helper'

class RepositorySourceTest < ActiveSupport::TestCase
  setup do
    @template_url = 'http://template.pl'
    @template = OpenStruct.new(name: 'MyTemplate')
    @subject = ForemanGitTemplates::Renderer::Source::Repository.new(@template, @template_url)
  end

  describe '#content' do
    test 'should return content' do
      repo_path = '/tmp/repo.tar.gz'
      content = 'content'

      ForemanGitTemplates::RepositoryFetcher.expects(:call).once.with(@template_url).returns(repo_path)
      ForemanGitTemplates::RepositoryReader.expects(:call).once.with(repo_path, @template.name).returns(content)

      assert_equal @subject.content, content
    end
  end

  describe '#find_snippet' do
    test 'should return snippet template' do
      snippet_name = 'MySnippet'
      snippet = @subject.find_snippet(snippet_name)

      assert snippet.is_a?(Template)
      assert snippet.respond_to?(:render)
      assert_equal snippet.name, snippet_name
    end
  end
end
