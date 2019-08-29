# frozen_string_literal: true

module ForemanGitTemplates
  module HostExtensions
    def repository_path
      return unless git_template_url

      git_template_tmpfile.path
    end

    private

    def git_template_url
      @git_template_url ||= host_params['template_url']
    end

    def git_template_tmpfile
      return unless git_template_url

      @git_template_tmpfile ||= RepositoryFetcher.call(git_template_url)
    end
  end
end
