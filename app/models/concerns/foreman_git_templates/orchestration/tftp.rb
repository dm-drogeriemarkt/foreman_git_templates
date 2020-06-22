# frozen_string_literal: true

module ForemanGitTemplates
  module Orchestration
    module TFTP
      extend ActiveSupport::Concern

      module Overrides
        delegate :render_template, to: :host

        def generate_pxe_template(kind)
          return super unless host.params['template_url']

          template = host.repository_klass.new(name: kind)
          render_template(template: template)
        rescue ForemanGitTemplates::RepositoryReader::MissingFileError
          nil
        end

        private

        def validate_tftp
          return super unless feasible_for_git_template_rendering?
          return unless tftp? || tftp6?
          return unless host.operatingsystem

          pxe_kind = host.operatingsystem.pxe_loader_kind(host)
          return unless pxe_kind && host.provisioning_template(kind: pxe_kind).nil?

          failure _('No %{kind} template was found for host %{host}. Repository url: %{url}') % { kind: pxe_kind, host: host.name, url: host.params['template_url'] }
        end

        def feasible_for_git_template_rendering?
          return false unless host.is_a?(Host::Managed)
          return false unless host.params['template_url']

          true
        end
      end

      included do
        prepend Overrides
      end
    end
  end
end
