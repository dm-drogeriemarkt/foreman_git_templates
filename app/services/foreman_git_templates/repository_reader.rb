# frozen_string_literal: true

module ForemanGitTemplates
  class RepositoryReader
    def initialize(repository, file)
      @repository = repository
      @file = file
    end

    def call
      Tar.untar(repository) do |tar|
        return tar.each { |e| break e.read if e.full_name.end_with?(file) }
      end
    end

    def self.call(repository, file)
      new(repository, file).call
    end

    private

    attr_reader :repository, :file
  end
end
