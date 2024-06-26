# frozen_string_literal: true

require 'test_plugin_helper'

class RepositoryFetcherTest < ActiveSupport::TestCase
  test 'should save a file' do
    Dir.mktmpdir do |dir|
      url = 'http://api.com/repository'
      repository_path = "#{dir}/repo.tar.gz"

      build_repository repository_path
      stub_request(:get, url).to_return(status: 200, body: repository_path)
      file_path = ForemanGitTemplates::RepositoryFetcher.call(url)

      assert File.exist?(file_path)
    end
  end

  test 'should raise RepositoryFetcherError when file does not exist' do
    url = 'http://api.com/repository'
    stub_request(:get, url).to_return(status: 404)

    msg = 'Response code: 404'
    assert_raises_with_message(ForemanGitTemplates::RepositoryFetcher::RepositoryFetcherError, msg) do
      ForemanGitTemplates::RepositoryFetcher.call(url)
    end
  end

  test 'should raise RepositoryFetcherError when url is incorrect' do
    url = 'incorrect_url'

    # "rest-client" normalizes a URL by adding a protocol if none is present
    requested_url = "http://#{url}"
    stub_request(:get, requested_url).to_return(status: 404)

    msg = 'Response code: 404'
    assert_raises_with_message(ForemanGitTemplates::RepositoryFetcher::RepositoryFetcherError, msg) do
      ForemanGitTemplates::RepositoryFetcher.call(url)
    end
  end
end
