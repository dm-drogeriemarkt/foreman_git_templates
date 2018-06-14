# frozen_string_literal: true

require 'test_plugin_helper'

module Host
  class ManagedTest < ActiveSupport::TestCase
    should have_one(:template_url_facet)

    test 'should save template_url' do
      host = FactoryBot.create(:host)
      template_url = 'http://www.template_url.com'
      assert_nil host.template_url

      host.template_url = template_url
      host.save
      host.reload

      assert host.template_url, template_url
    end
  end
end
