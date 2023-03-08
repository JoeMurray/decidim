# frozen_string_literal: true

require "spec_helper"

describe "Participatory Process Steps", type: :system do
  let(:organization) { create(:organization) }
  let!(:participatory_process) do
    create(
      :participatory_process,
      organization:,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
    )
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are some processes with steps" do
    let!(:steps) do
      create_list(:participatory_process_step, 3, participatory_process:)
    end

    before do
      participatory_process.steps.first.update!(active: true)
    end

    it_behaves_like "accessible page" do
      before do
        visit decidim_participatory_processes.participatory_process_participatory_process_steps_path(participatory_process)
      end
    end

    it "lists all the steps" do
      visit decidim_participatory_processes.participatory_process_participatory_process_steps_path(participatory_process)

      expect(page).to have_css(".timeline__item", count: 3)
      steps.each do |step|
        expect(page).to have_content(/#{translated(step.title)}/i)
      end
    end
  end
end
