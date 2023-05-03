# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class RelatedProcessesCell < Decidim::ContentBlocks::BaseCell
        def related_processes
          @related_processes ||=
            resource
            .linked_participatory_space_resources(:participatory_processes, "related_processes")
            .published
            .all
        end

        def filtered_processes
          return related_processes unless limit?

          related_processes.limit(limit)
        end

        def total_count
          related_processes.size
        end

        private

        def resource
          options[:resource] || super
        end

        def limit
          @limit ||= model.settings.try(:max_results)
        end

        def limit?
          limit.to_i.positive?
        end

        def title
          t("related_processes", scope: "decidim.participatory_processes.show")
        end
      end
    end
  end
end
