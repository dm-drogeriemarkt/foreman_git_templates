# frozen_string_literal: true

module ForemanGitTemplates
  class SnippetRepositoryTemplate < BaseRepositoryTemplate
    self.table_name = 'templates'

    def path
      "templates/snippets/#{name.downcase.tr(' ', '_')}.erb"
    end
  end
end
