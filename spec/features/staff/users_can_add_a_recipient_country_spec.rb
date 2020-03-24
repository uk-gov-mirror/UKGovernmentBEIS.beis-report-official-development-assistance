RSpec.feature "Users can add a recipient country on an activity" do
  let(:user) { create(:beis_user) }
  before { authenticate!(user: user) }

  scenario "when a user is filling an activity form, in the geography step" do
  activity = create(:activity, :at_geography_step)
  visit activity_step_path(activity, :geography)
  expect(page).to have_content("Will the benefitting recipient be a region or country?")

  choose "Country"
  click_button I18n.t("form.activity.submit")
  expect(page).to have_content I18n.t("page_title.activity_form.show.country")

  click_button I18n.t("form.activity.submit")
  expect(page).to have_content "can't be blank"
  end

    context "when JavaScript is enabled", js: true do
      scenario "the user will see the autocomplete" do
        activity = create(:activity, :at_geography_step)
        visit activity_step_path(activity, :geography)

        choose "Country"
        click_button I18n.t("form.activity.submit")

        expect(page).to have_css ".autocomplete-wrapper"
      end

    end

    context "when JavaScript is disabled", js: false do
      scenario "the user will see a select box" do
        activity = create(:activity, :at_geography_step)
        visit activity_step_path(activity, :geography)

        choose "Country"
        click_button I18n.t("form.activity.submit")

        expect(page).to have_css "select#activity-recipient-country-field"
      end
    end
end
