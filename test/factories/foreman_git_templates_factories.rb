# frozen_string_literal: true

FactoryBot.modify do
  factory :host do
    trait :with_template_url do
      after(:create) do |host, _evaluator|
        url = 'http://www.api.com/repository.tar.gz'
        WebMock::API.stub_request(:head, url).to_return(status: 200)
        FactoryBot.create(:host_parameter, host: host, name: 'template_url', value: url)
      end
    end
  end
end
