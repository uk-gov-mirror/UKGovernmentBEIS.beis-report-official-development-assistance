RSpec.feature "Users can submit a report" do
  context "as a Delivery partner user" do
    let(:delivery_partner_user) { create(:delivery_partner_user) }

    before do
      authenticate!(user: delivery_partner_user)
    end

    context "when the report is active" do
      scenario "they can submit a report" do
        report = create(:report, :active, organisation: delivery_partner_user.organisation)
        report_presenter = ReportPresenter.new(report)

        visit report_path(report)
        click_link t("action.report.submit.button")

        click_button t("action.report.submit.confirm.button")

        expect(page).to have_content t("action.report.submit.complete.title",
          report_organisation: report.organisation.name,
          report_financial_quarter: report_presenter.financial_quarter_and_year)
        expect(report.reload.state).to eql "submitted"
      end

      context "when the deadline is in the past" do
        scenario "they can still submit the report" do
          travel_to("2020-10-01") do
            fund = create(:fund_activity, actual_end_date: "2020-09-01")
            report = create(:report, :active, organisation: delivery_partner_user.organisation, fund: fund, deadline: "2020-09-01")
            report_presenter = ReportPresenter.new(report)

            visit report_path(report)
            click_link t("action.report.submit.button")

            click_button t("action.report.submit.confirm.button")

            expect(page).to have_content t("action.report.submit.complete.title",
                                           report_organisation: report.organisation.name,
                                           report_financial_quarter: report_presenter.financial_quarter_and_year)
            expect(report.reload.state).to eql "submitted"
          end
        end
      end

      scenario "a report submission is recorded in the audit log" do
        report = create(:report, state: :active, organisation: delivery_partner_user.organisation)
        PublicActivity.with_tracking do
          visit reports_path
          within "##{report.id}" do
            click_on t("default.link.view")
          end
          click_link t("action.report.submit.button")
          click_button t("action.report.submit.confirm.button")

          auditable_events = PublicActivity::Activity.all
          expect(auditable_events.last.key).to include("report.state.changed_to.submitted")
          expect(auditable_events.last.owner_id).to include delivery_partner_user.id
          expect(auditable_events.last.trackable_id).to include report.id
        end
      end
    end

    context "when the report is awaiting changes" do
      scenario "they can submit a report" do
        report = create(:report, :awaiting_changes, organisation: delivery_partner_user.organisation)
        report_presenter = ReportPresenter.new(report)

        visit report_path(report)
        click_link t("action.report.submit.button")

        click_button t("action.report.submit.confirm.button")

        expect(page).to have_content t("action.report.submit.complete.title",
          report_organisation: report.organisation.name,
          report_financial_quarter: report_presenter.financial_quarter_and_year)
        expect(report.reload.state).to eql "submitted"
      end
    end

    context "when the report is submitted" do
      scenario "they cannot submit a submitted report" do
        report = create(:report, state: :submitted, organisation: delivery_partner_user.organisation)

        visit report_path(report)

        expect(page).not_to have_link t("action.report.submit.button"), href: edit_report_state_path(report)

        visit edit_report_state_path(report)

        expect(page.status_code).to eql 401
      end
    end
  end

  context "when signed in as a BEIS user" do
    let(:beis_user) { create(:beis_user) }

    before do
      authenticate!(user: beis_user)
    end

    scenario "they cannot submit a report" do
      report = create(:report, state: :active)

      visit report_path(report)

      expect(page).not_to have_link t("action.report.submit.button"), href: edit_report_state_path(report)

      visit edit_report_state_path(report)

      expect(page.status_code).to eql 401
    end
  end
end
