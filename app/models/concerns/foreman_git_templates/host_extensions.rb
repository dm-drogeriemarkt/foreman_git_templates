# frozen_string_literal: true

module ForemanGitTemplates
  module HostExtensions
    def repository_path
      template_url = host_params['template_url']

      return unless template_url

      return @repository_path if @repository_path && File.exist?(@repository_path)

      @repository_path = RepositoryFetcher.call(template_url)
    end
  end
end
