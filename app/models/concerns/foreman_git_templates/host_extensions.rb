# frozen_string_literal: true

module ForemanGitTemplates
  module HostExtensions
    extend ActiveSupport::Concern

    included do
      delegate :template_url, to: :template_url_facet, allow_nil: true

      def template_url=(url)
        build_template_url_facet unless template_url_facet
        template_url_facet.send(:template_url=, url)
      end
    end
  end
end
