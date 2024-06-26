# frozen_string_literal: true

require 'rest-client'

module ForemanGitTemplates
  class RepositoryFetcher
    def initialize(repository_url)
      @repository_url = repository_url
    end

    def call
      RestClient::Request.execute(method: :get, url: repository_url, raw_response: true).file
    rescue RestClient::RequestFailed => e
      raise RepositoryFetcherError, "Cannot fetch repository from #{repository_url}. Response code: #{e.response.code}"
    rescue RestClient::Exception => e
      raise RepositoryFetcherError, "Cannot fetch repository from #{repository_url}, #{e.message}"
    end

    def self.call(repository_url)
      new(repository_url).call
    end

    private

    class RepositoryFetcherError < StandardError; end

    attr_reader :repository_url
  end
end
