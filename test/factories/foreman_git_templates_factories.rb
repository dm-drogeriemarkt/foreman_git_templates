# frozen_string_literal: true

FactoryBot.define do
  factory :template_url_facet, class: 'ForemanGitTemplates::TemplateUrlFacet' do
    template_url 'https://www.template_url.com'
    host
  end
end

FactoryBot.modify do
  factory :host do
    trait :with_template_url do
      template_url_facet
    end
  end
end
