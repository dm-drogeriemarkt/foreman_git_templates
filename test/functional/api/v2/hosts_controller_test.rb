# frozen_string_literal: true

require 'test_plugin_helper'

module Api
  module V2
    class HostsControllerTest < ActionController::TestCase
      let(:host) do
        as_admin do
          FactoryBot.create(:host, :with_template_url)
        end
      end

      test 'should returns template_url' do
        get :show, params: { id: host.to_param }
        assert_response :success
        show_response = ActiveSupport::JSON.decode(@response.body)
        assert_not show_response.empty?
        assert_equal host.template_url, show_response['template_url']
      end
    end
  end
end
