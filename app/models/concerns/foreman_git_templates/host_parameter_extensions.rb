# frozen_string_literal: true

module ForemanGitTemplates
  module HostParameterExtensions
    extend ActiveSupport::Concern

    included do
      validate :template_url_is_reachable, if: ->(p) { p.name == 'template_url' }
    end

    private

    def template_url_is_reachable
      RestClient::Request.execute(method: :head, url: value, timeout: Setting::GitTemplates['template_url_validation_timeout'])
    rescue RestClient::ExceptionWithResponse, URI::InvalidURIError, SocketError => e
      errors.add(:value, _('Cannot fetch templates from %{url}: %{error}') % { url: value, error: e.message })
    end
  end
end
