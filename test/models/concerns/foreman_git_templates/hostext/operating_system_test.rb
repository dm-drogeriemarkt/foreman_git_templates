# frozen_string_literal: true

require 'test_plugin_helper'

module Hostext
  class OperatingSystemTest < ActiveSupport::TestCase
    let(:host) { FactoryBot.create(:host, :managed, :with_template_url) }

    test 'available_template_kinds finds only templates that are defined in the repository' do
      Dir.mktmpdir do |dir|
        expected_kinds = ['PXEGrub', 'PXELinux', 'iPXE', 'PXEGrub2', 'provision']

        stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
          expected_kinds.each do |kind|
            tar.add_file_simple("templates/#{kind}/template.erb", 644, host.name.length) { |io| io.write(host.name) }
          end
        end

        actual = host.available_template_kinds('build').map(&:name)
        assert_same_elements expected_kinds, actual
      end
    end
  end
end
