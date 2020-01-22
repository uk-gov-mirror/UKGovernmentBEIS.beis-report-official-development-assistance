RSpec.feature "Users can create an activity" do
  let(:organisation) { create(:organisation, name: "UKSA") }

  context "when the user is not logged in" do
    it "redirects the user to the root path" do
      fund = create(:fund, organisation: organisation)
      activity = create(:activity, hierarchy: fund)
      page.set_rack_session(userinfo: nil)
      visit fund_activity_step_path(fund, activity, id: :identifier)
      expect(current_path).to eq(root_path)
    end
  end

  context "when the user is a fund_manager" do
    before { authenticate!(user: build_stubbed(:fund_manager, organisations: [organisation])) }

    scenario "successfully creates a fund activity with all optional information" do
      fund = create(:fund, organisation: organisation)

      visit dashboard_path
      click_on(I18n.t("page_content.dashboard.button.manage_organisations"))
      click_on(organisation.name)
      click_on(fund.title)

      click_on I18n.t("page_content.fund.button.create_activity", activity: "fund")

      fill_in_activity_form
    end

    scenario "the activity form has some defaults for funds" do
      fund = create(:fund, organisation: organisation)
      activity_presenter = ActivityPresenter.new(fund)
      visit organisation_fund_path(organisation, fund)

      click_on I18n.t("page_content.fund.button.create_activity", activity: "fund")

      visit fund_step_path(fund, :country)
      expect(page.find("option[@selected = 'selected']").text).to eq activity_presenter.recipient_region

      visit fund_step_path(fund, :flow)
      expect(page.find("option[@selected = 'selected']").text).to eq activity_presenter.flow

      visit fund_step_path(fund, :tied_status)
      expect(page.find("option[@selected = 'selected']").text).to eq activity_presenter.tied_status
    end

    context "validations" do
      scenario "validation errors work as expected" do
        visit organisation_path(organisation)
        click_on I18n.t("page_content.organisation.button.create_fund")

        # Don't provide an identifier
        click_button I18n.t("form.activity.submit")
        expect(page).to have_content "can't be blank"

        fill_in "fund[identifier]", with: "foo"
        click_button I18n.t("form.activity.submit")
        expect(page).to have_content I18n.t("page_title.activity_form.show.purpose")

        # Don't provide a title and description
        click_button I18n.t("form.activity.submit")
        expect(find_field("Title").value).to eq "Untitled fund"
        expect(page).to have_content "Description can't be blank"

        fill_in "fund[title]", with: Faker::Lorem.word
        fill_in "fund[description]", with: Faker::Lorem.paragraph
        click_button I18n.t("form.activity.submit")

        expect(page).to have_content I18n.t("page_title.activity_form.show.sector")

        # Don't provide a sector
        click_button I18n.t("form.activity.submit")
        expect(page).to have_content "Sector can't be blank"

        select "Education policy and administrative management", from: "fund[sector]"
        click_button I18n.t("form.activity.submit")
        expect(page).to have_content I18n.t("page_title.activity_form.show.status")

        # Don't provide a status
        click_button I18n.t("form.activity.submit")
        expect(page).to have_content "Status can't be blank"

        select "Implementation", from: "fund[status]"
        click_button I18n.t("form.activity.submit")

        expect(page).to have_content I18n.t("page_title.activity_form.show.dates")

        # Dates are not mandatory so we can move through this step
        click_button I18n.t("form.activity.submit")
        expect(page).to have_content I18n.t("page_title.activity_form.show.country")

        # Region has a default and can't be set to blank so we skip
        select "Developing countries, unspecified", from: "fund[recipient_region]"
        click_button I18n.t("form.activity.submit")
        expect(page).to have_content I18n.t("page_title.activity_form.show.flow")

        # Flow has a default and can't be set to blank so we skip
        select "ODA", from: "fund[flow]"
        click_button I18n.t("form.activity.submit")
        expect(page).to have_content I18n.t("page_title.activity_form.show.finance")

        # Don't select a finance
        click_button I18n.t("form.activity.submit")
        expect(page).to have_content "Finance can't be blank"

        select "Standard grant", from: "fund[finance]"
        click_button I18n.t("form.activity.submit")

        expect(page).to have_content I18n.t("page_title.activity_form.show.aid_type")

        # Don't select an aid type
        click_button I18n.t("form.activity.submit")
        expect(page).to have_content "Aid type can't be blank"

        select "General budget support", from: "fund[aid_type]"
        click_button I18n.t("form.activity.submit")

        expect(page).to have_content I18n.t("page_title.activity_form.show.tied_status")

        # Tied status has a default and can't be set to blank so we skip
        select "Untied", from: "fund[tied_status]"
        click_button I18n.t("form.activity.submit")
        expect(page).to have_content Fund.last.title
      end
    end

    scenario "can go back to the previous page" do
      fund = create(:fund, organisation: organisation)
      visit organisation_fund_path(organisation, fund)
      click_on I18n.t("page_content.fund.button.create_activity", activity: "fund")
      click_on I18n.t("generic.link.back")
      expect(page).to have_current_path(organisation_fund_path(fund.id, organisation_id: organisation.id))
    end
  end

  # TODO: When we come to create different types of activities for programmes etc
  # These journeys will start off the same but may eventually diverge with different
  # default form values etc. Bear this in mind when thinking about reuse.
  context "when the user is a delivery_partner" do
    before { authenticate!(user: build_stubbed(:delivery_partner, organisations: [organisation])) }

    # Create and Edit flows use the same URL, protecting it tests both
    # 'create?' and 'update?' actions in the ActivityPolicy
    scenario "cannot create an activity that belongs to a fund" do
      fund = create(:fund, organisation: organisation)
      activity = create(:activity, hierarchy: fund)

      visit fund_activity_step_path(fund, activity, id: :identifier)

      expect(page).to have_content(I18n.t("page_title.errors.not_authorised"))
    end
  end
end
