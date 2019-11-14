# frozen_string_literal: true

require 'test_plugin_helper'

module ForemanGitTemplates
  class HostTest < ActiveSupport::TestCase
    describe '#repository_path' do
      context 'with template_url parameter' do
        let(:repo_tempfile) { Tempfile.new }
        let(:repo_path) { repo_tempfile.path }
        let(:host) { FactoryBot.create(:host, :managed, :with_template_url) }

        it 'returns path to the repository' do
          ForemanGitTemplates::RepositoryFetcher.expects(:call).once.with(host.params['template_url']).returns(repo_tempfile)
          assert_equal repo_path, host.repository_path
        end
      end

      context 'without template_url parameter' do
        let(:host) { FactoryBot.create(:host, :managed) }

        it 'returns nil' do
          ForemanGitTemplates::RepositoryFetcher.expects(:call).never
          assert_nil host.repository_path
        end
      end
    end

    describe '#update' do
      let(:os) { FactoryBot.create(:operatingsystem, :with_associations, type: 'Redhat') }

      setup do
        host.expects(:skip_orchestration_for_testing?).at_least_once.returns(false)
      end

      context 'with valid template_url' do
        context 'when host is in build mode' do
          let(:host) { FactoryBot.create(:host, :with_tftp_orchestration, :with_template_url, operatingsystem: os, build: true) }

          it 'updates the host' do
            ProxyAPI::Resource.any_instance.stubs(:post).returns(true)
            ProxyAPI::TFTP.any_instance.stubs(:fetch_boot_file).returns(true)

            Dir.mktmpdir do |dir|
              stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
                tar.add_file_simple('templates/PXEGrub2/template.erb', 644, host.name.length) { |io| io.write(host.name) }
              end

              assert host.update(name: 'newname')
              assert_empty host.errors.messages
            end
          end
        end

        context 'when host is not in build mode' do
          let(:host) { FactoryBot.create(:host, :with_tftp_orchestration, :with_template_url, operatingsystem: os, build: false) }

          it 'updates the host' do
            ProxyAPI::TFTP.any_instance.stubs(:set).returns(true)

            Dir.mktmpdir do |dir|
              stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
                tar.add_file_simple('templates/PXEGrub2/default_local_boot.erb', 644, host.name.length) { |io| io.write(host.name) }
              end

              assert host.update(name: 'newname')
              assert_empty host.errors.messages
            end
          end
        end
      end

      context 'with invalid template_url' do
        setup do
          stub_request(:get, host.params['template_url']).to_return(status: 404)
        end

        let(:expected_errors) { ["No PXEGrub2 template was found for host #{host.name}. Repository url: #{host.params['template_url']}"] }

        context 'when host is in build mode' do
          let(:host) { FactoryBot.create(:host, :with_tftp_orchestration, :with_template_url, operatingsystem: os, build: true) }

          it 'does not update the host' do
            assert_equal false, host.update(name: 'newname')
            assert_equal expected_errors, host.errors[:base]
            assert_equal expected_errors, host.errors[:'interfaces.base']
          end
        end

        context 'when host is not in build mode' do
          let(:host) { FactoryBot.create(:host, :with_tftp_orchestration, :with_template_url, operatingsystem: os, build: false) }

          it 'does not update the host' do
            assert_equal false, host.update(name: 'newname')
            assert_equal expected_errors, host.errors[:base]
            assert_equal expected_errors, host.errors[:'interfaces.base']
          end
        end
      end
    end
  end
end
