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
          next if !entry.file? || !matched_with_file_or_directory?(entry.full_name)
          content = entry.read
          raise EmptyFileError, "The #{file} file is empty" if content.nil?
          break content
        end
      end
    rescue Errno::ENOENT
      raise RepositoryUnreadableError, "Cannot read repository from #{repository_path}"
    end

    def matched_with_file_or_directory?(path)
      path.downcase.split('/').map { |e| e.chomp('.erb') }.include?(file.downcase)
    end
  end
end
