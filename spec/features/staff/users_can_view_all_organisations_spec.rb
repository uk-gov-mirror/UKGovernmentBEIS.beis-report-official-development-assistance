RSpec.feature "Users can view all organisations" do
  before do
    authenticate!(user: user)
  end

  let(:user) { create(:user, organisations: [organisation]) }
  let(:organisation) { create(:organisation) }

  context "when the user is not logged in" do
    it "redirects the user to the root path" do
      page.set_rack_session(userinfo: nil)
      visit organisations_path
      expect(current_path).to eq(root_path)
    end
  end

  scenario "organisation index page" do
    organisation = FactoryBot.create(:organisation)

    visit organisations_path

    expect(page).to have_content(I18n.t("page_title.organisation.index"))
    expect(page).to have_content organisation.name
  end

  scenario "user does not see organisations they do not belong to" do
    skip "Not implemented yet"
    organisation_2 = create(:organisation)

    visit organisations_path

    expect(page).to have_content(I18n.t("page_title.organisation.index"))
    expect(page).to_not have_content organisation_2.name
  end

  scenario "can go back to the previous page" do
    visit organisations_path

    click_on I18n.t("generic.link.back")

    expect(page).to have_current_path(dashboard_path)
  end
end