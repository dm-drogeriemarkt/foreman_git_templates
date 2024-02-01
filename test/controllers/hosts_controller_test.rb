# frozen_string_literal: true

require 'test_plugin_helper'

class HostsControllerTest < ActionController::TestCase
  let(:host) { FactoryBot.create(:host, :managed, :with_template_url, build: true) }

  describe '#templates' do
    it 'returns only templates that are defined in the archive' do
      Dir.mktmpdir do |dir|
        expected_kinds = %w[PXEGrub PXELinux iPXE PXEGrub2 provision]

        stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
          expected_kinds.each do |kind|
            tar.add_file_simple("templates/#{kind}/template.erb", 644, host.name.length) { |io| io.write(host.name) }
          end
        end

        get :templates, params: { id: host.name }, session: set_session_user

        actual_kinds = @controller.instance_variable_get('@templates').map(&:name)
        assert_same_elements expected_kinds, actual_kinds
      end
    end
  end
end
