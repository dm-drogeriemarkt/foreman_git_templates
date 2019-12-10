# frozen_string_literal: true

module ForemanGitTemplates
  module HostExtensions
    extend ActiveSupport::Concern

    included do
      validates_associated :host_parameters
    end

    def repository_klass
      build? ? MainRepositoryTemplate : DefaultLocalBootRepositoryTemplate
    end

    def repository_path
      return unless git_template_url

      git_template_tmpfile&.path
    end

    private

    def git_template_url
      @git_template_url ||= host_params['template_url']
    end

    def git_template_tmpfile
      return unless git_template_url

      @git_template_tmpfile ||= RepositoryFetcher.call(git_template_url)
    rescue ::ForemanGitTemplates::RepositoryFetcher::RepositoryFetcherError => e
      Foreman::Logging.exception("GitTemplates: Failed to fetch data from #{git_template_url}", e)
      nil
    end
  end
end
