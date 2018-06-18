# frozen_string_literal: true

require 'test_plugin_helper'

class RepositoryReaderTest < ActiveSupport::TestCase
  test 'should returns file content' do
    Dir.mktmpdir do |dir|
      system("cd #{dir} && echo 'Hello' > README.md && tar -czf repo.tar.gz README.md")
      file = File.open("#{dir}/repo.tar.gz", 'rb')
      text = ForemanGitTemplates::RepositoryReader.new(file).read('README.md')

      assert text.include?('Hello')
    end
  end
end
