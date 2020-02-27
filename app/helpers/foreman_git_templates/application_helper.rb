# frozen_string_literal: true

module ForemanGitTemplates
  module ApplicationHelper
    extend ActiveSupport::Concern

    module Overrides
      def display_link_if_authorized(name, options = {}, html_options = {})
        # rubocop:disable Rails/HelperInstanceVariable

        return if @host&.repository_path && options[:use_route] == 'edit_provisioning_template'

        # rubocop:enable Rails/HelperInstanceVariable

        super
      end
    end

    included do
      prepend Overrides
    end
  end
end
