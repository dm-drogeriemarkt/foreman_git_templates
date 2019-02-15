# frozen_string_literal: true

require 'test_plugin_helper'

class UnattendedControllerTest < ActionController::TestCase
  let(:os) { FactoryBot.create(:operatingsystem, :with_archs, :with_ptables, type: 'Redhat') }
  let(:host) do
    FactoryBot.create(:host, :managed, :with_template_url, operatingsystem: os, ptable: os.ptables.first)
  end

  test 'should render template from repository' do
    assert_not_nil host.params['template_url']

    Dir.mktmpdir do |dir|
      kind = 'provision'

      stub_repository host.params['template_url'], "#{dir}/repo.tar.gz" do |tar|
        tar.add_file_simple("templates/#{kind}/whatever.erb", 644, host.name.length) { |io| io.write(host.name) }
      end

      get :host_template, params: { kind: kind, spoof: host.ip }, session: set_session_user
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
        tar.add_file_simple("templates/#{kind}/whatever.erb", 644, template_content.length) { |io| io.write(template_content) }
        tar.add_file_simple("templates/snippet/#{snippet_name}.erb", 644, snippet_content.length) { |io| io.write(snippet_content) }
      end

      get :host_template, params: { kind: kind, spoof: host.ip }, session: set_session_user
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
        tar.add_file_simple("templates/#{kind}/whatever.erb", 644, template_content.length) { |io| io.write(template_content) }
        tar.add_file_simple("templates/snippet/#{snippet_name}.erb", 644, snippet_content.length) { |io| io.write(snippet_content) }
        tar.add_file_simple("templates/snippet/#{nested_snippet_name}.erb", 644, nested_snippet_content.length) { |io| io.write(nested_snippet_content) }
      end

      get :host_template, params: { kind: kind, spoof: host.ip }, session: set_session_user
      assert_response :success
      assert_equal 'foo bar', response.body.strip
    end
  end
end
