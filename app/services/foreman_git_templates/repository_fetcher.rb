# frozen_string_literal: true

require 'down'

module ForemanGitTemplates
  class RepositoryFetcher
    def initialize(repository_url)
      @repository_url = repository_url
    end

    def call
      Down.download(repository_url).path
    rescue Down::ResponseError => e
      raise CannotFetchRepository, "Cannot fetch repository from #{repository_url}. Response code: #{e.response.code}"
    rescue Down::Error => e
      raise CannotFetchRepository, "Cannot fetch repository from #{repository_url}, #{e.message}"
    end

    def self.call(repository_url)
      new(repository_url).call
    end

    private

    class CannotFetchRepository < StandardError; end

    attr_reader :repository_url
  end
end
