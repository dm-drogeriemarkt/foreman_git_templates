# frozen_string_literal: true

require 'test_plugin_helper'

class UnattendedControllerTest < ActionController::TestCase
  let(:os) { FactoryBot.create(:operatingsystem, :with_associations, type: 'Redhat') }
  let(:host) do
    FactoryBot.create(:host, :managed, :with_template_url, build: true, operatingsystem: os, ptable: os.ptables.first)
  end

  test 'should render template from repository' do
    assert_not_nil host.params['template_url']

    Dir.mktmpdir do |dir|
      kind = 'provision'

      stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
        tar.add_file_simple("templates/#{kind}/template.erb", 644, host.name.length) { |io| io.write(host.name) }
      end

      get :host_template, params: { kind: kind, hostname: host.name }, session: set_session_user
      assert_response :success
      assert_equal host.name, response.body.strip
    end
  end

  test 'should render snippet from repository' do
    assert_not_nil host.params['template_url']

    Dir.mktmpdir do |dir|
      kind = 'PXELinux'
      snippet_name = 'MySnippet'
      snippet_content = 'foo: <%= @foo %>'
      template_content = "<%= snippet('#{snippet_name}', variables: { foo: 'bar' }) %>"

      stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
        tar.add_file_simple("templates/#{kind}/template.erb", 644, template_content.length) { |io| io.write(template_content) }
        tar.add_file_simple("templates/snippets/#{snippet_name.downcase}.erb", 644, snippet_content.length) { |io| io.write(snippet_content) }
      end

      get :host_template, params: { kind: kind, hostname: host.name }, session: set_session_user
      assert_response :success
      assert_equal 'foo: bar', response.body.strip
    end
  end

  test 'snippet should render nested snippet' do
    assert_not_nil host.params['template_url']

    Dir.mktmpdir do |dir|
      nested_snippet_name = 'MyNestedSnippet'
      nested_snippet_content = '<%= @foo %><%= @bar %>'

      snippet_name = 'MySnippet'
      snippet_content = "<%= @foo %> <%= snippet('#{nested_snippet_name}', variables: { bar: 'bar' }) %>"

      kind = 'PXELinux'
      template_content = "<%= snippet('#{snippet_name}', variables: { foo: 'foo' }) %>"

      stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
        tar.add_file_simple("templates/#{kind}/template.erb", 644, template_content.length) { |io| io.write(template_content) }
        tar.add_file_simple("templates/snippets/#{snippet_name.downcase}.erb", 644, snippet_content.length) { |io| io.write(snippet_content) }
        tar.add_file_simple("templates/snippets/#{nested_snippet_name.downcase}.erb", 644, nested_snippet_content.length) { |io| io.write(nested_snippet_content) }
      end

      get :host_template, params: { kind: kind, hostname: host.name }, session: set_session_user
      assert_response :success
      assert_equal 'foo bar', response.body.strip
    end
  end

  describe 'iPXE templates' do
    let(:host) do
      FactoryBot.create(:host, :managed, :with_template_url, build: false, operatingsystem: os, ptable: os.ptables.first)
    end

    context 'host not in build mode' do
      test 'should render iPXE local boot template from repository' do
        assert_not_nil host.params['template_url']

        Dir.mktmpdir do |dir|
          kind = 'iPXE'

          stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
            tar.add_file_simple("templates/#{kind}/default_local_boot.erb", 644, 5) { |io| io.write('local') }
            tar.add_file_simple("templates/#{kind}/template.erb", 644, host.name.length) { |io| io.write(host.name) }
          end

          get :host_template, params: { kind: kind, hostname: host.name }, session: set_session_user
          assert_response :success
          assert_equal 'local', response.body.strip
        end
      end
    end

    context 'host in build mode' do
      setup do
        host.update!(build: true)
      end

      test 'should render iPXE template from repository' do
        host.reload
        assert_not_nil host.params['template_url']

        Dir.mktmpdir do |dir|
          kind = 'iPXE'

          stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
            tar.add_file_simple("templates/#{kind}/default_local_boot.erb", 644, 5) { |io| io.write('local') }
            tar.add_file_simple("templates/#{kind}/template.erb", 644, host.name.length) { |io| io.write(host.name) }
          end

          get :host_template, params: { kind: kind, hostname: host.name }, session: set_session_user
          assert_response :success
          assert_equal host.name, response.body.strip
        end
      end
    end
  end
end
