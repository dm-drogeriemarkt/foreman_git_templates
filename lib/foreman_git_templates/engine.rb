# frozen_string_literal: true

module ForemanGitTemplates
  class Engine < ::Rails::Engine
    engine_name 'foreman_git_templates'

    config.autoload_paths += Dir["#{config.root}/app/lib"]
    config.autoload_paths += Dir["#{config.root}/app/services"]
    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]

    initializer 'foreman_git_templates.load_default_settings', before: :load_config_initializers do
      require_dependency File.expand_path('../../app/models/setting/git_templates.rb', __dir__) if begin
                                                                                                     Setting.table_exists?
                                                                                                   rescue StandardError
                                                                                                     (false)
                                                                                                   end
    end

    initializer 'foreman_git_templates.register_plugin', before: :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_git_templates do
        requires_foreman '>= 2.3'
      end
    end

    # Include concerns in this config.to_prepare block
    config.to_prepare do
      Foreman::Renderer.singleton_class.prepend(ForemanGitTemplates::Renderer)
      Host::Managed.include(ForemanGitTemplates::Hostext::OperatingSystem)
      Host::Managed.include(ForemanGitTemplates::HostExtensions)
      HostParameter.include(ForemanGitTemplates::HostParameterExtensions)
      Nic::Managed.include(ForemanGitTemplates::Orchestration::TFTP)
      UnattendedController.include(ForemanGitTemplates::UnattendedControllerExtensions)
      ::ApplicationHelper.include(ForemanGitTemplates::ApplicationHelper)
    rescue StandardError => e
      Rails.logger.warn "ForemanGitTemplates: skipping engine hook (#{e})"
    end
  end
end
