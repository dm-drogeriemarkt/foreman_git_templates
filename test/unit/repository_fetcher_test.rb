# frozen_string_literal: true

require 'test_plugin_helper'

class RepositoryFetcherTest < ActiveSupport::TestCase
  test 'should returns Tempfile' do
    Dir.mktmpdir do |dir|
      system("cd #{dir} && touch README.md && tar -czf repo.tar.gz README.md")
      stub_request(:get, 'http://api.com/repository').to_return(status: 200, body: File.new("#{dir}/repo.tar.gz"))
      tempfile = ForemanGitTemplates::RepositoryFetcher.call('http://api.com/repository')

      assert tempfile.is_a?(Tempfile)
    end
  end
end
