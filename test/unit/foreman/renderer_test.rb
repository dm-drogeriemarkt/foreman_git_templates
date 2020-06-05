# frozen_string_literal: true

require 'test_plugin_helper'

class RendererTest < ActiveSupport::TestCase
  describe '.get_source' do
    subject { Foreman::Renderer.get_source(template: template, host: host, klass: source_klass) }

    let(:template) { FactoryBot.create(:provisioning_template) }

    context 'when the host has a template_url defined' do
      let(:host) { FactoryBot.create(:host, :with_template_url) }

      context 'when the source class is not passed' do
        let(:source_klass) { nil }

        it 'uses ForemanGitTemplates::Renderer::Source::Repository' do
          Dir.mktmpdir do |dir|
            stub_repository host.params['template_url'], "#{dir}/repo.tar.gz"

            assert_equal ForemanGitTemplates::Renderer::Source::Repository, subject.class
          end
        end
      end

      context 'when the source class is implicitly passed' do
        let(:source_klass) { Foreman::Renderer::Source::Database }

        it { assert_equal Foreman::Renderer::Source::Database, subject.class }
      end
    end

    context 'when the host has no template_url defined' do
      let(:host) { FactoryBot.create(:host) }
      let(:source_klass) { nil }

      it { assert_equal Foreman::Renderer::Source::Database, subject.class }
    end
  end
end
