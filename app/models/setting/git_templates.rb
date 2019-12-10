# frozen_string_literal: true

class Setting
  class GitTemplates < ::Setting
    def self.default_settings
      [
        set('template_url_validation_timeout', N_('Template URL validation timeout in seconds'), 15, N_('Template URL validation timeout'))
      ]
    end

    def self.load_defaults
      # Check the table exists
      return unless super

      transaction do
        default_settings.each { |s| create! s.update(category: 'Setting::GitTemplates') }
      end

      true
    end

    def self.humanized_category
      N_('GitTemplates')
    end
  end
end
