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
          @content ||= ForemanGitTemplates::RepositoryReader.call(repository_path, filename)
        end

        private

        attr_reader :template_url

        def repository_path
          @repository_path ||= ForemanGitTemplates::RepositoryFetcher.call(template_url)
        end

        def filename
          @filename ||= "#{name}.erb".tr(' ', '_')
        end
      end
    end
  end
end
