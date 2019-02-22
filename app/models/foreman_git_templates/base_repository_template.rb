# frozen_string_literal: true

module ForemanGitTemplates
  class BaseRepositoryTemplate < ::ProvisioningTemplate
    self.table_name = 'templates'

    after_initialize do
      self.template_kind = TemplateKind.find_by(name: name)
    end

    def path
      raise NotImplementedError
    end
  end
end
