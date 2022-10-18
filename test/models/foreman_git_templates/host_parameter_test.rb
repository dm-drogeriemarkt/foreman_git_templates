# frozen_string_literal: true

require 'test_plugin_helper'

module ForemanGitTemplates
  class HostParameterTest < ActiveSupport::TestCase
    describe 'template_url validation' do
      let(:template_url) { 'http://api.com/repo.tar.gz' }
      let(:host) { FactoryBot.create(:host) }
      let(:host_parameter) { FactoryBot.build(:host_parameter, name: 'template_url', value: template_url, host: host) }

      context 'when template_url returns 200' do
        it 'is valid' do
          stub_request(:head, template_url).to_return(status: 200)

          assert host_parameter.valid?
        end
      end

      context 'when template_url returns 401' do
        it 'is invlid' do
          stub_request(:head, template_url).to_return(status: 401)

          assert_not host_parameter.valid?
          assert_not_empty host_parameter.errors[:value]
        end
      end

      context 'when template_url returns 404' do
        it 'is invlid' do
          stub_request(:head, template_url).to_return(status: 404)

          assert_not host_parameter.valid?
          assert_not_empty host_parameter.errors[:value]
        end
      end

      context 'when template_url returns 500' do
        it 'is invlid' do
          stub_request(:head, template_url).to_return(status: 500)

          assert_not host_parameter.valid?
          assert_not_empty host_parameter.errors[:value]
        end
      end

      context 'when template_url is not a valid URL' do
        let(:template_url) { 'not URL value' }

        it 'is invlid' do
          assert_not host_parameter.valid?
          assert_not_empty host_parameter.errors[:value]
        end
      end
    end
  end
end
