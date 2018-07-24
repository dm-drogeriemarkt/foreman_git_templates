# frozen_string_literal: true

module ForemanGitTemplates
  module Renderer
    def get_source(klass: Foreman::Renderer::Source::Database, template:, **args)
      template_url = template_url(args[:host])
      if template_url
        ForemanGitTemplates::Renderer::Source::Repository.new(template, template_url)
      else
        super
      end
    end

    private

    def template_url(host)
      host.try(:host_params).try(:fetch, 'template_url', nil)
    end
  end
end
