# frozen_string_literal: true

module ForemanGitTemplates
  class RepositoryReader
    def initialize(repository_path, file)
      @repository_path = repository_path
      @file = file
    end

    def call
      raise MissingFileError, "The #{file} file is missing" if content.nil?
      content
    end

    def self.call(repository_path, file)
      new(repository_path, file).call
    end

    private

    class RepositoryReaderError < StandardError; end
    class RepositoryUnreadableError < RepositoryReaderError; end
    class FileUnreadableError < RepositoryReaderError; end
    class MissingFileError < FileUnreadableError; end
    class EmptyFileError < FileUnreadableError; end

    attr_reader :repository_path, :file

    def content
      @content ||= Tar.untar(repository_path) do |tar|
        return tar.each do |entry|
          next unless entry.file? && entry.full_name.end_with?(file)
          break entry.read.tap do |entry_content|
            raise EmptyFileError, "The #{file} file is empty" if entry_content.nil?
          end
        end
      end
    rescue Errno::ENOENT
      raise RepositoryUnreadableError, "Cannot read repository from #{repository_path}"
    end
  end
end
