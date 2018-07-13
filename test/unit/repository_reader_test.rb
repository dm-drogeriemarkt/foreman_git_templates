# frozen_string_literal: true

require 'test_plugin_helper'

class RepositoryReaderTest < ActiveSupport::TestCase
  test 'should return file content' do
    Dir.mktmpdir do |dir|
      repository_path = "#{dir}/repo.tar.gz"
      file_name = 'README.md'
      file_content = 'Hello'

      ForemanGitTemplates::Tar.tar(repository_path) do |tar|
        tar.add_file_simple(file_name, 644, file_content.length) { |io| io.write(file_content) }
      end

      result = ForemanGitTemplates::RepositoryReader.call(repository_path, file_name)
      assert result.include?(file_content)
    end
  end
end
