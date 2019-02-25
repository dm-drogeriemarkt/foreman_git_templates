# frozen_string_literal: true

require 'test_plugin_helper'

class RepositoryReaderTest < ActiveSupport::TestCase
  test 'should return file content' do
    Dir.mktmpdir do |dir|
      repository_path = "#{dir}/repo.tar.gz"
      file_name = 'files/README.md'
      file_content = 'Hello'

      build_repository repository_path do |tar|
        tar.add_file_simple(file_name, 644, file_content.length) { |io| io.write(file_content) }
      end

      result = ForemanGitTemplates::RepositoryReader.call(repository_path, file_name)
      assert_equal file_content, result
    end
  end

  context 'with custom root directory' do
    test 'should return file content' do
      Dir.mktmpdir do |dir|
        repository_path = "#{dir}/repo.tar.gz"
        root_dir = 'root'
        file_name = 'files/README.md'
        file_content = 'Hello'

        build_repository repository_path do |tar|
          tar.add_file_simple("#{root_dir}/#{file_name}", 644, file_content.length) { |io| io.write(file_content) }
        end

        result = ForemanGitTemplates::RepositoryReader.call(repository_path, file_name)
        assert_equal file_content, result
      end
    end
  end

  test 'should raise RepositoryUnreadableError when repository does not exist' do
    Dir.mktmpdir do |dir|
      repository_path = "#{dir}/repo.tar.gz"

      assert_raises(ForemanGitTemplates::RepositoryReader::RepositoryUnreadableError) do
        ForemanGitTemplates::RepositoryReader.call(repository_path, 'file')
      end
    end
  end

  test 'should raise MissingFileError when file does not exist' do
    Dir.mktmpdir do |dir|
      repository_path = "#{dir}/repo.tar.gz"
      filename = 'file.erb'
      build_repository repository_path

      assert_raises(ForemanGitTemplates::RepositoryReader::MissingFileError) do
        ForemanGitTemplates::RepositoryReader.call(repository_path, filename)
      end
    end
  end

  test 'should raise EmptyFileError when file is empty' do
    Dir.mktmpdir do |dir|
      repository_path = "#{dir}/repo.tar.gz"
      file_name = 'files/README.md'
      file_content = ''

      build_repository repository_path do |tar|
        tar.add_file_simple(file_name, 644, file_content.length) { |io| io.write(file_content) }
      end

      assert_raises(ForemanGitTemplates::RepositoryReader::EmptyFileError) do
        ForemanGitTemplates::RepositoryReader.call(repository_path, file_name)
      end
    end
  end
end
