module ForemanGitTemplates
  class Engine < ::Rails::Engine
    engine_name 'foreman_git_templates'

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]

    # Add any db migrations
    initializer 'foreman_git_templates.load_app_instance_data' do |app|
      ForemanGitTemplates::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer 'foreman_git_templates.register_plugin', :before => :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_git_templates do
        requires_foreman '>= 1.16'

        # Add permissions
        security_block :foreman_git_templates do
          permission :view_foreman_git_templates, :'foreman_git_templates/hosts' => [:new_action]
        end

        # Add a new role called 'Discovery' if it doesn't exist
        role 'ForemanGitTemplates', [:view_foreman_git_templates]

        # add menu entry
        menu :top_menu, :template,
             url_hash: { controller: :'foreman_git_templates/hosts', action: :new_action },
             caption: 'ForemanGitTemplates',
             parent: :hosts_menu,
             after: :hosts

        # add dashboard widget
        widget 'foreman_git_templates_widget', name: N_('Foreman plugin template widget'), sizex: 4, sizey: 1
      end
    end

    # Include concerns in this config.to_prepare block
    config.to_prepare do
      begin
        Host::Managed.send(:include, ForemanGitTemplates::HostExtensions)
        HostsHelper.send(:include, ForemanGitTemplates::HostsHelperExtensions)
      rescue => e
        Rails.logger.warn "ForemanGitTemplates: skipping engine hook (#{e})"
      end
    end

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        ForemanGitTemplates::Engine.load_seed
      end
    end

    initializer 'foreman_git_templates.register_gettext', after: :load_config_initializers do |_app|
      locale_dir = File.join(File.expand_path('../../..', __FILE__), 'locale')
      locale_domain = 'foreman_git_templates'
      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end
  end
end
