# frozen_string_literal: true

module Decidim
  module Assemblies
    class AssemblyPresenter < SimpleDelegator
      def hero_image_url
        assembly.attached_uploader(:hero_image).url(host: assembly.organization.host)
      end

      def banner_image_url
        assembly.attached_uploader(:banner_image).url(host: assembly.organization.host)
      end

      def area_name
        return if assembly.area.blank?

        Decidim::AreaPresenter.new(assembly.area).translated_name_with_type
      end

      def duration
        return I18n.t("indefinite_duration", scope: "decidim.assemblies.assemblies.description") if (date = assembly.duration).blank?

        I18n.l(date, format: :decidim_short)
      end

      def closing_date
        return if (date = assembly.closing_date).blank?

        I18n.l(date, format: :decidim_short)
      end

      def assembly
        __getobj__
      end
    end
  end
end
