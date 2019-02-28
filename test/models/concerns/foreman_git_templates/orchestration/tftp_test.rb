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
          stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
            tar.add_file_simple("templates/#{kind}/template.erb", 644, template_content.length) { |io| io.write(template_content) }
            tar.add_file_simple("templates/#{kind}/default_local_boot.erb", 644, default_local_boot_template_content.length) { |io| io.write(default_local_boot_template_content) }
          end

          assert_equal default_local_boot_template_content, host.generate_pxe_template('PXELinux')
        end
      end

      it 'does not generate a pxe template if the corresponding template file is missing in the repo' do
        Dir.mktmpdir do |dir|
          stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
            tar.add_file_simple("templates/#{kind}/template.erb", 644, template_content.length) { |io| io.write(template_content) }
            tar.add_file_simple("templates/#{kind}/default_local_boot.erb", 644, default_local_boot_template_content.length) { |io| io.write(default_local_boot_template_content) }
          end

          assert_nil host.generate_pxe_template('PXEGrub2')
        end
      end

      it 'raises an exception when generating a pxe template if the corresponding default local boot template file is missing in the repo' do
        Dir.mktmpdir do |dir|
          stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
            tar.add_file_simple("templates/#{kind}/template.erb", 644, template_content.length) { |io| io.write(template_content) }
          end

          assert_raises ForemanGitTemplates::RepositoryReader::MissingFileError do
            host.generate_pxe_template('PXELinux')
          end
        end
      end
    end
  end

  describe '#setTFTP' do
    let(:os) { FactoryBot.create(:operatingsystem, :with_media, :with_archs, :with_ptables, type: 'Redhat') }
    let(:subnet) { FactoryBot.build(:subnet_ipv4, :tftp, :with_taxonomies) }
    let(:interfaces) do
      [
        FactoryBot.build(:nic_bond,
                         primary: true,
                         identifier: 'bond0',
                         attached_devices: ['eth0', 'eth1'],
                         provision: true,
                         domain: FactoryBot.build_stubbed(:domain),
                         subnet: subnet,
                         mac: nil,
                         ip: subnet.network.sub(/0\Z/, '2')),
        FactoryBot.build(:nic_interface,
                         identifier: 'eth0',
                         mac: '00:53:67:ab:dd:00'),
        FactoryBot.build(:nic_interface,
                         identifier: 'eth1',
                         mac: '00:53:67:ab:dd:01')
      ]
    end
    let(:host) do
      FactoryBot.create(:host,
                        :managed,
                        :with_template_url,
                        :with_tftp_orchestration,
                        subnet: subnet,
                        interfaces: interfaces,
                        build: true,
                        location: subnet.locations.first,
                        organization: subnet.organizations.first,
                        operatingsystem: os,
                        ptable: os.ptables.first,
                        medium: os.media.first)
    end

    let(:kind) { 'PXELinux' }
    let(:template_content) { 'main template content' }
    let(:default_local_boot_template_content) { 'default local boot template content' }

    context 'host is in build mode' do
      setup do
        host.update(build: true)
      end

      it 'sends the main template from the tar archive to the smart proxy' do
        assert_not_nil host.params['template_url']

        Dir.mktmpdir do |dir|
          stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
            tar.add_file_simple("templates/#{kind}/template.erb", 644, template_content.length) { |io| io.write(template_content) }
            tar.add_file_simple("templates/#{kind}/default_local_boot.erb", 644, default_local_boot_template_content.length) { |io| io.write(default_local_boot_template_content) }
          end

          ProxyAPI::TFTP.any_instance.expects(:set).with(kind, '00:53:67:ab:dd:00', pxeconfig: template_content).once
          ProxyAPI::TFTP.any_instance.expects(:set).with(kind, '00:53:67:ab:dd:01', pxeconfig: template_content).once

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

          ProxyAPI::TFTP.any_instance.expects(:set).with(kind, '00:53:67:ab:dd:00', pxeconfig: default_local_boot_template_content).once
          ProxyAPI::TFTP.any_instance.expects(:set).with(kind, '00:53:67:ab:dd:01', pxeconfig: default_local_boot_template_content).once

          host.provision_interface.send(:setTFTP, kind)
        end
      end
    end
  end
end
