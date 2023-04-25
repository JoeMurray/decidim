# frozen_string_literal: true

module Decidim
  # This cell is used to display metadata inside a list card
  # so other cells only have to customize a few methods or overwrite views.
  class CardMetadataCell < Decidim::ViewModel
    include Decidim::IconHelper
    include Decidim::ApplicationHelper
    include Decidim::SanitizeHelper
    include ActionView::Helpers::DateHelper

    alias resource model

    def show
      return if items.blank?

      render
    end

    def initialize(*)
      super

      @items ||= []
      @items << space_item if show_space?
    end

    private

    def space_item
      return unless show_space?

      {
        text: decidim_html_escape(translated_attribute(participatory_space.title)),
        icon: resource_type_icon_key(participatory_space.class),
        url: Decidim::ResourceLocatorPresenter.new(participatory_space).path
      }
    end

    def comments_count_item
      return unless model.is_a?(Decidim::Comments::Commentable) && model.commentable?
      return if (count = model.comments_count).zero?

      {
        text: count,
        icon: resource_type_icon_key(:comments_count)
      }
    end

    def endorsements_count_item
      return unless resource.respond_to?(:endorsements_count)
      return if (count = resource.endorsements_count).zero?

      {
        text: count,
        icon: resource_type_icon_key(:like),
        data_attributes: { endorsements_count: "" }
      }
    end

    def author_item
      return unless authorable?

      presented_author = official? ? "#{resource.class.module_parent}::OfficialAuthorPresenter".constantize.new : present(resource.author)

      {
        cell: "decidim/redesigned_author",
        args: [presented_author, { from: resource, skip_profile_link: true, context_actions: [] }]
      }
    end

    def coauthors_item
      # REDESIGN_PENDING - Define a cell to deal with coauthors of a resource.
      # For the moment this item only shows first coauthor
      return unless coauthorable?

      presented_author = official? ? "#{resource.class.module_parent}::OfficialAuthorPresenter".constantize.new : present(resource.identities.first)

      {
        cell: "decidim/redesigned_author",
        args: [presented_author, { from: resource, skip_profile_link: true, context_actions: [] }]
      }
    end

    def emendation_item
      # REDESIGN_DETAILS - Maybe this item should be moved to another part of
      # the card instead of the metadata list
      return unless resource.try(:emendation?)

      {
        icon: resource_type_icon_key("other"),
        text: t("decidim/amendment", scope: "activerecord.models", count: 1)
      }
    end

    def dates_item
      return if dates_blank?

      format = [start_date.year, end_date.year].any? { |year| year != Date.current.year } ? :decidim_short_with_month_name_short : :decidim_with_month_name_short
      text = if start_date.to_date == end_date.to_date
               "#{l(start_date.to_date, format:)} #{l(start_date, format: :time_of_day)} - #{l(end_date, format: :time_of_day)}"
             else
               "#{l(start_date.to_date, format:)} - #{l(end_date.to_date, format:)}"
             end

      {
        text:,
        icon: "timer-2-line"
      }
    end

    def duration_item
      return if dates_blank?

      {
        text: distance_of_time_in_words(start_date, end_date, scope: "datetime.distance_in_words.short"),
        icon: "time-line"
      }
    end

    def enable_links?
      return false unless options.has_key?(:links)

      options[:links]
    end

    def show_space?
      (context[:show_space].presence || options[:show_space].presence) && resource.respond_to?(:participatory_space) && resource.participatory_space.present?
    end

    def participatory_space
      return unless show_space?

      @participatory_space ||= resource.participatory_space
    end

    def items
      @items.compact
    end

    def official?
      resource.respond_to?(:official?) && resource.official?
    end

    def authorable?
      @authorable ||= resource.is_a?(Decidim::Authorable)
    end

    def coauthorable?
      @coauthorable ||= resource.is_a?(Decidim::Coauthorable)
    end

    def start_date
      nil
    end

    def end_date
      nil
    end

    def dates_blank?
      [start_date, end_date].any?(&:blank?)
    end

    def current_date
      @current_date ||= Date.current.to_time
    end

    def progress_item
      return if progress_value.blank?

      {
        text: "#{progress_span}#{progress_text}".html_safe
      }
    end

    def progress_value
      return if dates_blank?

      @progress_value ||= (end_date - current_date).to_f / (end_date - start_date) if current_date <= end_date
    end

    def progress_span
      return if progress_value.blank?

      "<span class=\"card__grid-loader\" style=\"--value:#{progress_value};\"></span>"
    end

    def progress_text
      return if progress_value.blank?

      @progress_text ||= if start_date.present? && current_date < start_date
                           t("not_started", scope: "decidim.metadata.progress")
                         elsif end_date.blank?
                           t("active", scope: "decidim.metadata.progress")
                         elsif current_date < end_date
                           t("remaining", time_distance: distance_of_time_in_words(current_date, end_date), scope: "decidim.metadata.progress")
                         else
                           t("finished", scope: "decidim.metadata.progress")
                         end
    end
  end
end
