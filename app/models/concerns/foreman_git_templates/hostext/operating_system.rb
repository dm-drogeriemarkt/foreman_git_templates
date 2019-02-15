# frozen_string_literal: true

module ForemanGitTemplates
  module Hostext
    module OperatingSystem
      extend ActiveSupport::Concern

      module Overrides
        def provisioning_template(opts = {})
          return super unless host_params['template_url']
          kind = opts[:kind] || 'provision'
          Template.new(name: kind)
        end

        def available_template_kinds(provisioning = nil)
          return super unless host_params['template_url']

          repository_path = RepositoryFetcher.call(host_params['template_url'])
          template_kinds(provisioning).map do |kind|
            RepositoryReader.call(repository_path, kind.name)
            Template.new(name: kind.name)
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
