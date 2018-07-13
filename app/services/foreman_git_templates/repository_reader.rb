# frozen_string_literal: true

module ForemanGitTemplates
  class RepositoryReader
    def initialize(repository_path, file)
      @repository_path = repository_path
      @file = file
    end

    def call
      Tar.untar(repository_path) do |tar|
        return tar.each { |e| break e.read if e.full_name.downcase.end_with?(file.downcase) }
      end
    end

    def self.call(repository_path, file)
      new(repository_path, file).call
    end

    private

    attr_reader :repository_path, :file
  end
end
