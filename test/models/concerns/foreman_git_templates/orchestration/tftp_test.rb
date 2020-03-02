# frozen_string_literal: true

require 'test_plugin_helper'

class TFTPOrchestrationTest < ActiveSupport::TestCase
  describe '#generate_pxe_template' do
    let(:kind) { 'PXELinux' }
    let(:template_content) { 'main template content' }
    let(:default_local_boot_template_content) { 'default local boot template content' }

    context 'host is in build mode' do
      let(:host) { FactoryBot.create(:host, :managed, :with_template_url, build: true) }

      it 'renders main template' do
        Dir.mktmpdir do |dir|
          stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
            tar.add_file_simple("templates/#{kind}/template.erb", 644, template_content.length) { |io| io.write(template_content) }
          end

          assert_equal template_content, host.generate_pxe_template(kind)
        end
      end

      context 'when corresponding default local boot template file is missing in the repo' do
        it 'does not generate a pxe template' do
          Dir.mktmpdir do |dir|
            stub_repository host.params['template_url'], "#{dir}/repo.tar.gz"

            assert_nil host.generate_pxe_template(kind)
          end
        end
      end
    end

    context 'host is not in build mode' do
      let(:host) { FactoryBot.create(:host, :managed, :with_template_url, build: false) }

      it 'renders default local boot template' do
        Dir.mktmpdir do |dir|
          stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
            tar.add_file_simple("templates/#{kind}/default_local_boot.erb", 644, default_local_boot_template_content.length) { |io| io.write(default_local_boot_template_content) }
          end

          assert_equal default_local_boot_template_content, host.generate_pxe_template(kind)
        end
      end

      context 'when corresponding default local boot template file is missing in the repo' do
        it 'does not generate a pxe template' do
          Dir.mktmpdir do |dir|
            stub_repository host.params['template_url'], "#{dir}/repo.tar.gz"

            assert_nil host.generate_pxe_template(kind)
          end
        end
      end
    end
  end

  describe '#validate_tftp' do
    let(:host) { FactoryBot.create(:host, :with_tftp_orchestration, :with_template_url, build: false, pxe_loader: 'PXELinux BIOS') }
    let(:kind) { 'PXELinux' }
    let(:template_content) { 'main template content' }
    let(:default_local_boot_template_content) { 'default local boot template content' }

    context 'host is in build mode' do
      setup do
        host.primary_interface.expects(:valid?).returns(true) if Gem::Version.new(SETTINGS[:version].notag) >= Gem::Version.new('2.0')
        host.update(build: true)
      end

      it 'validates that the host is ready for tftp' do
        Dir.mktmpdir do |dir|
          stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
            tar.add_file_simple("templates/#{kind}/template.erb", 644, template_content.length) { |io| io.write(template_content) }
            tar.add_file_simple("templates/#{kind}/default_local_boot.erb", 644, default_local_boot_template_content.length) { |io| io.write(default_local_boot_template_content) }
          end

          host.provision_interface.send(:validate_tftp)
          assert_empty host.errors.messages
        end
      end
    end

    context 'host is not build mode' do
      it 'validates that the host is ready for tftp' do
        Dir.mktmpdir do |dir|
          stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
            tar.add_file_simple("templates/#{kind}/template.erb", 644, template_content.length) { |io| io.write(template_content) }
            tar.add_file_simple("templates/#{kind}/default_local_boot.erb", 644, default_local_boot_template_content.length) { |io| io.write(default_local_boot_template_content) }
          end

          host.provision_interface.send(:validate_tftp)
          assert_empty host.errors.messages
        end
      end
    end
  end

  describe '#setTFTP' do
    let(:host) { FactoryBot.create(:host, :with_tftp_orchestration, :with_template_url, pxe_loader: 'PXELinux BIOS') }

    let(:kind) { 'PXELinux' }
    let(:template_content) { 'main template content' }
    let(:default_local_boot_template_content) { 'default local boot template content' }

    context 'host is in build mode' do
      setup do
        host.primary_interface.expects(:valid?).returns(true) if Gem::Version.new(SETTINGS[:version].notag) >= Gem::Version.new('2.0')
        host.update(build: true)
      end

      it 'sends the main template from the tar archive to the smart proxy' do
        assert_not_nil host.params['template_url']

        Dir.mktmpdir do |dir|
          stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
            tar.add_file_simple("templates/#{kind}/template.erb", 644, template_content.length) { |io| io.write(template_content) }
            tar.add_file_simple("templates/#{kind}/default_local_boot.erb", 644, default_local_boot_template_content.length) { |io| io.write(default_local_boot_template_content) }
          end

          ProxyAPI::TFTP.any_instance.expects(:set).with(kind, host.interfaces.first.mac, pxeconfig: template_content).once

          host.provision_interface.send(:setTFTP, kind)
        end
      end
    end

    context 'host is not in build mode' do
      setup do
        host.update(build: false)
      end

      it 'sends the local boot template from the tar archive to the smart proxy' do
        assert_not_nil host.params['template_url']

        Dir.mktmpdir do |dir|
          stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
            tar.add_file_simple("templates/#{kind}/template.erb", 644, template_content.length) { |io| io.write(template_content) }
            tar.add_file_simple("templates/#{kind}/default_local_boot.erb", 644, default_local_boot_template_content.length) { |io| io.write(default_local_boot_template_content) }
          end

          ProxyAPI::TFTP.any_instance.expects(:set).with(kind, host.interfaces.first.mac, pxeconfig: default_local_boot_template_content).once

          host.provision_interface.send(:setTFTP, kind)
        end
      end
    end
  end
end
