# frozen_string_literal: true

module ForemanGitTemplates
  module Renderer
    module Source
      class Repository < Foreman::Renderer::Source::Base
        def initialize(template, template_url)
          @template = template
          @template_url = template_url
        end

        def content
          @content ||= ForemanGitTemplates::RepositoryReader.call(repository_path, template_path)
        end

        def find_snippet(name)
          SnippetRepositoryTemplate.new(name: name)
        end

        private

        attr_reader :template_url
        delegate :path, to: :template, prefix: true

        def repository_path
          @repository_path ||= ForemanGitTemplates::RepositoryFetcher.call(template_url)
        end
      end
    end
  end
end
