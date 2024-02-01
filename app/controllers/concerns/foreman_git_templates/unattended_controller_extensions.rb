# frozen_string_literal: true

module ForemanGitTemplates
  module UnattendedControllerExtensions
    extend ActiveSupport::Concern

    module Overrides
      def render_local_boot_template
        return super unless @host&.repository_path

        return unless verify_found_host

        template = ForemanGitTemplates::DefaultLocalBootRepositoryTemplate.new(name: 'iPXE')
        safe_render(template)
      rescue ForemanGitTemplates::RepositoryReader::MissingFileError
        render_ipxe_message(message: _('iPXE default local boot template not found in repository at templates/iPXE/default_local_boot.erb')) # rubocop:disable Layout/LineLength
      end
    end

    included do
      prepend Overrides
    end
  end
end
