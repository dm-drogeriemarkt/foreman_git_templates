# frozen_string_literal: true

require 'test_plugin_helper'

class TFTPOrchestrationTest < ActiveSupport::TestCase
  describe '#generate_pxe_template' do
    context 'host is in build mode' do
      let(:host) { FactoryBot.create(:host, :managed, :with_template_url, build: true) }

      it 'renders main template' do
        Dir.mktmpdir do |dir|
          kind = 'PXELinux'
          template_content = 'main template content'
          default_local_boot_template_content = 'default local boot template content'

          stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
            tar.add_file_simple("templates/#{kind}/template.erb", 644, template_content.length) { |io| io.write(template_content) }
            tar.add_file_simple("templates/#{kind}/default_local_boot.erb", 644, default_local_boot_template_content.length) { |io| io.write(default_local_boot_template_content) }
          end

          assert_equal template_content, host.generate_pxe_template('PXELinux')
        end
      end
    end

    context 'host is not in build mode' do
      let(:host) { FactoryBot.create(:host, :managed, :with_template_url, build: false) }

      it 'renders default local boot template' do
        Dir.mktmpdir do |dir|
          kind = 'PXELinux'
          template_content = 'main template content'
          default_local_boot_template_content = 'default local boot template content'

          stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
            tar.add_file_simple("templates/#{kind}/template.erb", 644, template_content.length) { |io| io.write(template_content) }
            tar.add_file_simple("templates/#{kind}/default_local_boot.erb", 644, default_local_boot_template_content.length) { |io| io.write(default_local_boot_template_content) }
          end

          assert_equal default_local_boot_template_content, host.generate_pxe_template('PXELinux')
        end
      end
    end
  end
end
