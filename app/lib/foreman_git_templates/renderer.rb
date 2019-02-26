# frozen_string_literal: true

module ForemanGitTemplates
  module Renderer
    def get_source(klass: Foreman::Renderer::Source::Database, template:, **args)
      repository_path = repository_path(args[:host])
      if repository_path
        ForemanGitTemplates::Renderer::Source::Repository.new(template, repository_path)
      else
        super
      end
    end

    private

    def repository_path(host)
      host.try(:repository_path)
    end
  end
end
