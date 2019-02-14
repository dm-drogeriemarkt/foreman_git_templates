# frozen_string_literal: true

module ForemanGitTemplates
  class RepositoryReader
    def initialize(repository_path, file)
      @repository_path = repository_path
      @file = file
    end

    def call
      raise FileUnreadableError, "Cannot read #{file} from repository" if content.nil?
      content
    end

    def self.call(repository_path, file)
      new(repository_path, file).call
    end

    private

    class RepositoryReaderError < StandardError; end
    class RepositoryUnreadableError < RepositoryReaderError; end
    class FileUnreadableError < RepositoryReaderError; end

    attr_reader :repository_path, :file

    def content
      @content ||= begin
        Tar.untar(repository_path) do |tar|
          return tar.each { |entry| break entry.read if entry.file? && matched_with_file_or_directory?(entry.full_name) }
        end
      rescue Errno::ENOENT
        raise RepositoryUnreadableError, "Cannot read repository from #{repository_path}"
      end
    end

    def matched_with_file_or_directory?(path)
      path.downcase.split('/').map { |e| e.chomp('.erb') }.include?(file.downcase)
    end
  end
end
