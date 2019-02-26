# frozen_string_literal: true

module ForemanGitTemplates
  module HostExtensions
    def repository_path
      return unless host_params['template_url']

      @repository_path ||= RepositoryFetcher.call(host_params['template_url'])
    end
  end
end
