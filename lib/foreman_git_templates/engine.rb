# frozen_string_literal: true

module ForemanGitTemplates
  class Engine < ::Rails::Engine
    engine_name 'foreman_git_templates'

    config.autoload_paths += Dir["#{config.root}/app/lib"]
    config.autoload_paths += Dir["#{config.root}/app/services"]
    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]

    initializer 'foreman_git_templates.register_plugin', before: :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_git_templates do
        requires_foreman '>= 3.1'

        settings do
          category :git_templates, N_('Git Templates') do
            setting :template_url_validation_timeout,
              type: :integer,
              default: 15,
              description: _('Template URL validation timeout in seconds')
          end
        end
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
