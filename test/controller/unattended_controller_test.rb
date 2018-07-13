# frozen_string_literal: true

require 'test_helper'

class UnattendedControllerTest < ActionController::TestCase
  setup do
    org = FactoryBot.create(:organization, ignore_types: ['ProvisioningTemplate'])
    loc = FactoryBot.create(:location, ignore_types: ['ProvisioningTemplate'])
    ptable = FactoryBot.create(:ptable, name: 'default', operatingsystem_ids: [operatingsystems(:redhat).id])
    @host = FactoryBot.create(:host, :managed, :with_template_url,
                              operatingsystem: operatingsystems(:redhat),
                              ptable: ptable,
                              organization: org,
                              location: loc)
    stub_request(:get, @host.host_params['template_url'])
      .to_return(status: 200, body: File.new(repository_path))
  end

  test 'should render template from repository' do
    get :host_template, params: { kind: 'provision', spoof: @host.ip }, session: set_session_user

    assert_response :success
    # template content: "<%= @host.name %>"
    assert_equal response.body.strip, @host.name
  end
end
