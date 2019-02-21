# frozen_string_literal: true

module ForemanGitTemplates
  module Orchestration
    module TFTP
      extend ActiveSupport::Concern

      module Overrides
        delegate :render_template, to: :host

        def generate_pxe_template(kind)
          return super unless host.params['template_url']

          template_klass = build? ? DefaultLocalBootRepositoryTemplate : MainRepositoryTemplate
          template = template_klass.new(name: kind)
          render_template(template: template)
        end
      end

      included do
        prepend Overrides
      end
    end
  end
end
