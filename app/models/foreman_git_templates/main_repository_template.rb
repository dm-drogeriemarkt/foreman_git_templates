# frozen_string_literal: true

module ForemanGitTemplates
  class MainRepositoryTemplate < BaseRepositoryTemplate
    self.table_name = 'templates'

    def path
      "templates/#{name}/template.erb"
    end
  end
end
