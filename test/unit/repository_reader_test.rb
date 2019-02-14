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
      assert_equal file_content, result
    end
  end

  test 'should find a file in the directory and return its contents' do
    Dir.mktmpdir do |dir|
      repository_path = "#{dir}/repo.tar.gz"
      dir_name = 'provision'
      file_name = 'my_template.erb'
      file_content = 'template'
      another_file_content = 'blah'

      ForemanGitTemplates::Tar.tar(repository_path) do |tar|
        tar.add_file_simple("#{dir_name}_copy/whatever.erb", 644, another_file_content.length) { |io| io.write(another_file_content) }
        tar.add_file_simple("#{dir_name}/#{file_name}", 644, file_content.length) { |io| io.write(file_content) }
      end

      result = ForemanGitTemplates::RepositoryReader.call(repository_path, dir_name)
      assert_equal file_content, result
    end
  end

  test 'should raise RepositoryUnreadableError when repository does not exist' do
    Dir.mktmpdir do |dir|
      repository_path = "#{dir}/repo.tar.gz"

      msg = "Cannot read repository from #{repository_path}"
      assert_raises_with_message(ForemanGitTemplates::RepositoryReader::RepositoryUnreadableError, msg) do
        ForemanGitTemplates::RepositoryReader.call(repository_path, 'file.erb')
      end
    end
  end

  test 'should raise FileUnreadableError when file does not exist' do
    Dir.mktmpdir do |dir|
      repository_path = "#{dir}/repo.tar.gz"
      filename = 'file.erb'
      ForemanGitTemplates::Tar.tar(repository_path)

      msg = "Cannot read #{filename} from repository"
      assert_raises_with_message(ForemanGitTemplates::RepositoryReader::FileUnreadableError, msg) do
        ForemanGitTemplates::RepositoryReader.call(repository_path, filename)
      end
    end
  end
end
