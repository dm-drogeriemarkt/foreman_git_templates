# frozen_string_literal: true

require 'test_plugin_helper'

class RepositoryFetcherTest < ActiveSupport::TestCase
  test 'should save a file' do
    Dir.mktmpdir do |dir|
      url = 'http://api.com/repository'
      archive_path = "#{dir}/repo.tar.gz"

      ForemanGitTemplates::Tar.tar(archive_path)
      stub_request(:get, url).to_return(status: 200, body: archive_path)
      file_path = ForemanGitTemplates::RepositoryFetcher.call(url)

      assert File.exist?(file_path)
    end
  end
end
