# frozen_string_literal: true

module ForemanGitTemplates
  module Renderer
    REPOSITORY_SOURCE_CLASS = ForemanGitTemplates::Renderer::Source::Repository

    def get_source(klass: nil, template:, **args)
      return super if klass && klass != REPOSITORY_SOURCE_CLASS

      repository_path = repository_path(args[:host])
      if repository_path
        REPOSITORY_SOURCE_CLASS.new(template, repository_path)
      elsif !repository_path && Gem::Version.new(SETTINGS[:version].version) < Gem::Version.new('1.23')
        super(klass: klass || Foreman::Renderer::Source::Database, template: template, **args)
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
