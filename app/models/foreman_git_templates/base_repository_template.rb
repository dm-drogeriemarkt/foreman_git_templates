# frozen_string_literal: true

module ForemanGitTemplates
  class BaseRepositoryTemplate < ::ProvisioningTemplate
    self.table_name = 'templates'

    def path
      raise NotImplementedError
    end
  end
end
