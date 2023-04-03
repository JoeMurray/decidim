# frozen_string_literal: true

module Decidim
  module Dev
    # Decidim's development Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Dev
      engine_name "decidim_dev"

      initializer "decidim_admin.mount_routes" do |_app|
        Decidim::Core::Engine.routes do
          namespace :design do
            get "forms", to: "forms#index"
            get "cards", to: "cards#index"
          end
        end
      end

      initializer "decidim_dev.tools" do
        ActiveSupport.on_load :action_controller do
          ActionController::Base.include Decidim::Dev::NeedsDevelopmentTools
        end
      end

      initializer "decidim_dev.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
