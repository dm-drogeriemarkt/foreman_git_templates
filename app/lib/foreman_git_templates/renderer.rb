# frozen_string_literal: true

module ForemanGitTemplates
  module Renderer
    def render_template(template: nil, subjects: {}, params: {}, variables: {})
      source = subjects[:source]
      host = subjects[:host]

      if !source && (template_url = template_url(host))
        source = ForemanGitTemplates::Renderer::Source::Repository.new(template, template_url)
        super(subjects: subjects.merge(source: source),
              params: params, variables: variables)
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
