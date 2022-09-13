# frozen_string_literal: true

require "spec_helper"

describe "Admin imports assembly", type: :system do
  include_context "when admin administrating an assembly"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.assemblies_path
  end

  context "when importing the assembly with basic fields" do
    before do
      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/assembly/hero_image/1/city.jpeg",
        "image/jpeg"
      )
      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/assembly/banner_image/1/city2.jpeg",
        "image/jpeg"
      )
      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/attachment/file/31/Exampledocument.pdf",
        "application/pdf"
      )
      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/attachment/file/32/city.jpeg",
        "image/jpeg"
      )

      click_link "Import", match: :first

      within ".import_assembly" do
        fill_in_i18n(
          :assembly_title,
          "#assembly-title-tabs",
          en: "Import assembly",
          es: "Importación de la asamblea",
          ca: "Importació de l'asamblea"
        )
        fill_in :assembly_slug, with: "as-import"
      end

      dynamically_attach_file(:assembly_document, Decidim::Dev.asset("assemblies.json"))
      click_button "Import"
    end

    it "imports the json document" do
      expect(page).to have_content("successfully")
      expect(page).to have_content("Import assembly")
      expect(page).to have_content("Not published")

      click_link "Import assembly"

      click_link "Categories"
      within ".table-list" do
        expect(page).to have_content(translated("Veritatis provident nobis reprehenderit tenetur."))
        expect(page).to have_content(translated("Quidem aliquid reiciendis incidunt iste."))
      end

      click_link "Components"
      expect(Decidim::Assembly.last.components.size).to eq(9)
      within ".table-list" do
        Decidim::Assembly.last.components.each do |component|
          expect(page).to have_content(translated(component.name))
        end
      end

      click_link "Files"
      if Decidim::Assembly.last.attachments.any?
        within ".table-list" do
          Decidim::Assembly.last.attachments.each do |attachment|
            expect(page).to have_content(translated(attachment.title))
          end
        end
      end
    end
  end
end
