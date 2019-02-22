# frozen_string_literal: true

module ForemanGitTemplates
  class DefaultLocalBootRepositoryTemplate < BaseRepositoryTemplate
    self.table_name = 'templates'

    def path
      "templates/#{name}/default_local_boot.erb"
    end
  end
end
