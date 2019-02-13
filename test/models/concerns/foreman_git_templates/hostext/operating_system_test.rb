# frozen_string_literal: true

require 'test_plugin_helper'

module Hostext
  class OperatingSystemTest < ActiveSupport::TestCase
    let(:host) { FactoryBot.create(:host, :managed, :with_template_url) }

    test 'available_template_kinds finds only templates that are defined in the repository' do
      Dir.mktmpdir do |dir|
        kinds = TemplateKind.all.pluck(:name)
        expected_kinds = kinds.first(3)
        unexpected_kinds = kinds - expected_kinds

        repository_path = "#{dir}/repo.tar.gz"

        ForemanGitTemplates::Tar.tar(repository_path) do |tar|
          expected_kinds.each do |kind|
            tar.add_file_simple("templates/#{kind}/whatever.erb", 644, host.name.length) { |io| io.write(host.name) }
          end
        end

        stub_request(:get, host.host_params['template_url'])
          .to_return(status: 200, body: File.new(repository_path))

        actual = host.available_template_kinds('build')

        expected_kinds.each do |kind|
          template = actual.find { |t| t.name == kind }
          assert template
        end
        unexpected_kinds.each do |kind|
          template = actual.find { |t| t.name == kind }
          refute template
        end
      end
    end
  end
end
