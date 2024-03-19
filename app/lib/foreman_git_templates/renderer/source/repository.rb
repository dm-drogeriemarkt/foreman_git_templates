# frozen_string_literal: true

module ForemanGitTemplates
  module Renderer
    module Source
      class Repository < Foreman::Renderer::Source::Base
        def initialize(template, repository_path)
          super(template)
          @repository_path = repository_path
        end

        def content
          @content ||= ForemanGitTemplates::RepositoryReader.call(repository_path, template_path)
        end

        def find_snippet(name)
          SnippetRepositoryTemplate.new(name: name)
        end

        private

        attr_reader :repository_path

        delegate :path, to: :template, prefix: true
      end
    end
  end
end
