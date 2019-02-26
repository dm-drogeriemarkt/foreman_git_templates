# frozen_string_literal: true

module ForemanGitTemplates
  module Orchestration
    module TFTP
      extend ActiveSupport::Concern

      module Overrides
        delegate :render_template, to: :host

        def generate_pxe_template(kind)
          return super unless host.repository_path

          template_klass = build? ? MainRepositoryTemplate : DefaultLocalBootRepositoryTemplate
          template = template_klass.new(name: kind)
          render_template(template: template)
        rescue ForemanGitTemplates::RepositoryReader::MissingFileError => e
          # re-raise the exception if we have a main template defined for this type
          raise e if host.available_template_kinds.map(&:name).include?(kind)
          nil
        end
      end

      included do
        prepend Overrides
      end
    end
  end
end
