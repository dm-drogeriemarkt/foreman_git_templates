# frozen_string_literal: true

module ForemanGitTemplates
  module Hostext
    module OperatingSystem
      extend ActiveSupport::Concern

      module Overrides
        def provisioning_template(opts = {})
          return super unless repository_path

          kind = opts[:kind] || 'provision'
          available_template_kinds.find { |template| template.name == kind }
        end

        def available_template_kinds(provisioning = nil)
          return super unless repository_path

          @available_template_kinds ||= template_kinds(provisioning).map do |kind|
            MainRepositoryTemplate.new(name: kind.name).tap do |template|
              RepositoryReader.call(repository_path, template.path)
            end
          rescue RepositoryReader::FileUnreadableError # file is missing or empty
            next
          end.compact
        end
      end

      included do
        prepend Overrides
      end
    end
  end
end
