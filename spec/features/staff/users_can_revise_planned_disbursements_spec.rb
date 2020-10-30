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

    scenario "they can edit a revised planned disbursement" do
      activity = create(:programme_activity)
      _planned_disbursement = create(:planned_disbursement, parent_activity: activity)
      revised_planned_disbursement = create(:planned_disbursement, parent_activity: activity, planned_disbursement_type: :revised, value: 11000)

      visit organisation_activity_financials_path(activity.organisation, activity)
      within "##{revised_planned_disbursement.id}" do
        click_on "Edit revised forecasted spend"
      end

      planned_disbursement_presenter = PlannedDisbursementPresenter.new(revised_planned_disbursement)

      expect(page).to have_content activity.title
      expect(page).to have_content activity.delivery_partner_identifier
      expect(page).to have_content t("page_title.planned_disbursement.revision.edit")
      expect(page).to have_content planned_disbursement_presenter.financial_quarter_and_year
      expect(page).to have_content planned_disbursement_presenter.value

      fill_in "planned_disbursement[value]", with: "12000"
      click_on "Revise forecasted spend"

      expect(page).to have_content t("action.planned_disbursement.revision.update.success")
      within "##{revised_planned_disbursement.id}" do
        expect(page).to have_content "£12,000.00"
      end
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

    scenario "they can edit a revised planned disbursement" do
      activity = create(:project_activity, organisation: user.organisation)
      report = create(:report, state: :active, fund: activity.associated_fund, organisation: activity.organisation)
      _planned_disbursement = create(:planned_disbursement, parent_activity: activity)
      revised_planned_disbursement = create(:planned_disbursement, parent_activity: activity, planned_disbursement_type: :revised, value: 11000, report: report)

      visit organisation_activity_financials_path(activity.organisation, activity)
      within "##{revised_planned_disbursement.id}" do
        click_on "Edit revised forecasted spend"
      end

      planned_disbursement_presenter = PlannedDisbursementPresenter.new(revised_planned_disbursement)

      expect(page).to have_content activity.title
      expect(page).to have_content activity.delivery_partner_identifier
      expect(page).to have_content t("page_title.planned_disbursement.revision.edit")
      expect(page).to have_content planned_disbursement_presenter.financial_quarter_and_year
      expect(page).to have_content planned_disbursement_presenter.value

      fill_in "planned_disbursement[value]", with: "12000"
      click_on "Revise forecasted spend"

      expect(page).to have_content t("action.planned_disbursement.revision.update.success")
      within "##{revised_planned_disbursement.id}" do
        expect(page).to have_content "£12,000.00"
      end
    end

    scenario "they can cancel a revision" do
      activity = create(:project_activity, organisation: user.organisation)
      prior_report = create(:report, organisation: user.organisation, fund: activity.associated_fund, state: :approved)
      _active_report = create(:report, organisation: user.organisation, fund: activity.associated_fund, state: :active)
      _original_planned_disbursement = create(:planned_disbursement, parent_activity: activity, report: prior_report)

      visit organisation_activity_financials_path(activity.organisation, activity)
      click_on "Revise forecasted spend"
      click_on t("default.button.cancel")

      expect(page).not_to have_content t("action.planned_disbursement.revision.create.success")
      expect(activity.planned_disbursements.count).to eq 1
    end
  end
end
