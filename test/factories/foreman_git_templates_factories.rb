# frozen_string_literal: true

FactoryBot.modify do
  factory :host do
    trait :with_template_url do
      after(:create) do |host, _evaluator|
        FactoryBot.create(:host_parameter, host: host, name: 'template_url', value: 'http://www.api.com/repository.tar.gz')
      end
    end
  end
end
