# frozen_string_literal: true

require 'down'

module ForemanGitTemplates
  class RepositoryFetcher
    def initialize(repo_url)
      @repo_url = repo_url
    end

    def call
      Down.download(repo_url)
    end

    def self.call(repo_url)
      new(repo_url).call
    end

    private

    attr_reader :repo_url
  end
end
