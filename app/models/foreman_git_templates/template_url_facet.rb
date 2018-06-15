# frozen_string_literal: true

module ForemanGitTemplates
  class TemplateUrlFacet < ApplicationRecord
    include Facets::Base

    belongs_to :host, class_name: 'Host::Managed', inverse_of: :template_url_facet

    validates_lengths_from_database
    validates :host, presence: true, allow_blank: false
  end
end
