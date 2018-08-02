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
      end

      included do
        prepend Overrides
      end
    end
  end
end
