# frozen_string_literal: true

module ForemanGitTemplates
  module Api
    module V2
      module HostsControllerExtensions
        extend Apipie::DSL::Concern

        update_api(:create, :update) do
          param :host, Hash do
            param :template_url, String, desc: 'Template URL'
          end
        end
      end
    end
  end
end
