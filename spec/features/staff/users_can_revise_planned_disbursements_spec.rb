RSpec.feature "Users can revise planned disbursments" do
  context "when the user belongs to BEIS" do
    let(:user) { create(:beis_user) }
    before { authenticate!(user: user) }

    scenario "they can add a revised planned disbursement to an existing planned_disbursement" do
      activity = create(:programme_activity)
      planned_disbursement = create(:planned_disbursement, parent_activity: activity)

      visit organisation_activity_financials_path(activity.organisation, activity)
      within "##{planned_disbursement.id}" do
        expect(page).to have_content "Edit"
        click_on "Revise forecasted spend"
      end

      planned_disbursement_presenter = PlannedDisbursementPresenter.new(planned_disbursement)

      expect(page).to have_content activity.title
      expect(page).to have_content activity.delivery_partner_identifier
      expect(page).to have_content t("page_title.planned_disbursement.revision.new")
      expect(page).to have_content planned_disbursement_presenter.financial_quarter_and_year
      expect(page).to have_content planned_disbursement_presenter.value
    end
  end

  context "when the user belongs to a delivery partner" do
    let(:user) { create(:delivery_partner_user) }
    before { authenticate!(user: user) }

    scenario "they can add a new revision to an existing planned disbursement" do
      activity = create(:project_activity, organisation: user.organisation)
      prior_report = create(:report, organisation: user.organisation, fund: activity.associated_fund, state: :approved)
      _active_report = create(:report, organisation: user.organisation, fund: activity.associated_fund, state: :active)
      original_planned_disbursement = create(:planned_disbursement, parent_activity: activity, report: prior_report)

      visit organisation_activity_financials_path(activity.organisation, activity)
      within "##{original_planned_disbursement.id}" do
        expect(page).not_to have_content "Edit"
        click_on "Revise forecasted spend"
      end

      original_planned_disbursement_presenter = PlannedDisbursementPresenter.new(original_planned_disbursement)

      expect(page).to have_content activity.title
      expect(page).to have_content activity.delivery_partner_identifier
      expect(page).to have_content t("page_title.planned_disbursement.revision.new")
      expect(page).to have_content original_planned_disbursement_presenter.financial_quarter_and_year
      expect(page).to have_content original_planned_disbursement_presenter.value
    end
  end
end
