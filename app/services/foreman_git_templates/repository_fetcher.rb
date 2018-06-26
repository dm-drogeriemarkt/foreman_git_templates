# frozen_string_literal: true

require 'down'

module ForemanGitTemplates
  class RepositoryFetcher
    def initialize(repository_url)
      @repository_url = repository_url
    end

    def call
      Down.download(repository_url).path
    end

    def self.call(repository_url)
      new(repository_url).call
    end

    private

    attr_reader :repository_url
  end
end
