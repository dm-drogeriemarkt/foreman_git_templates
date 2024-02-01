# frozen_string_literal: true

class FixGitTemplatesSettingsCategoryToDsl < ActiveRecord::Migration[6.0]
  class MigrationSettings < ActiveRecord::Base
    self.table_name = :settings
  end

  def up
    MigrationSettings.where(category: 'Setting::GitTemplates').update_all(category: 'Setting') if column_exists?(:settings, :category)
  end
end
