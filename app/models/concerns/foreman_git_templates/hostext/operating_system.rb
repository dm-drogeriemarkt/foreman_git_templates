# frozen_string_literal: true

module ForemanGitTemplates
  module Hostext
    module OperatingSystem
      extend ActiveSupport::Concern

      module Overrides
        def provisioning_template(opts = {})
          return super unless repository_path

          kind = opts[:kind].to_s || 'provision'
          available_template_kinds.find { |template| template.name == kind }
        end

        def available_template_kinds(provisioning = nil)
          return super unless repository_path

          # rubocop:disable Layout/RescueEnsureAlignment
          @available_template_kinds ||= template_kinds(provisioning).map do |kind|
            repository_klass.new(name: kind.name).tap do |t|
              t.template = RepositoryReader.call(repository_path, t.path)
            end
          rescue RepositoryReader::FileUnreadableError # file is missing or empty
            next
          end.compact
          # rubocop:enable Layout/RescueEnsureAlignment
        end
      end

      included do
        prepend Overrides
      end
    end
  end
end
