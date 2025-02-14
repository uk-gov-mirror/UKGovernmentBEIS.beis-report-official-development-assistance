require "rails_helper"

RSpec.describe Staff::ActivityFormsController do
  let(:user) { create(:delivery_partner_user, organisation: organisation) }
  let(:organisation) { create(:delivery_partner_organisation) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:logged_in_using_omniauth?).and_return(true)
  end

  describe "#show" do
    context "when editing a fund" do
      let(:activity) { create(:fund_activity, organisation: organisation) }

      context "gcrf_challenge_area step" do
        subject { get_step :gcrf_challenge_area }

        it { is_expected.to skip_to_next_step }

        context "when activity is the GCRF fund" do
          let(:activity) { create(:fund_activity, :gcrf, organisation: organisation) }

          it { is_expected.to skip_to_next_step }
        end
      end
    end

    context "when editing a programme" do
      let(:fund) { create(:fund_activity) }
      let(:activity) { create(:programme_activity, organisation: organisation, parent: fund) }

      context "gcrf_challenge_area step" do
        subject { get_step :gcrf_challenge_area }

        it { is_expected.to skip_to_next_step }

        context "when activity is the GCRF fund" do
          let(:activity) { create(:project_activity, organisation: organisation, parent: fund, source_fund_code: Fund::MAPPINGS["GCRF"]) }

          it { is_expected.to render_current_step }
        end
      end

      context "gcrf_strategic_area step" do
        subject { get_step :gcrf_strategic_area }

        it { is_expected.to skip_to_next_step }

        context "when activity is the GCRF fund" do
          let(:activity) { create(:project_activity, organisation: organisation, parent: fund, source_fund_code: Fund::MAPPINGS["GCRF"]) }

          it { is_expected.to render_current_step }
        end
      end
    end

    context "when editing a project" do
      let(:fund) { create(:fund_activity) }
      let(:programme) { create(:programme_activity, parent: fund) }
      let(:activity) { create(:project_activity, organisation: organisation, parent: programme) }

      context "gcrf_challenge_area step" do
        subject { get_step :gcrf_challenge_area }

        it { is_expected.to skip_to_next_step }

        context "when activity is associated with the GCRF fund" do
          let(:activity) { create(:project_activity, organisation: organisation, parent: programme, source_fund_code: Fund::MAPPINGS["GCRF"]) }

          it { is_expected.to render_current_step }
        end
      end
    end

    context "when editing a third-party project" do
      let(:fund) { create(:fund_activity) }
      let(:programme) { create(:programme_activity, parent: fund) }
      let(:project) { create(:project_activity, parent: programme) }
      let(:activity) { create(:third_party_project_activity, organisation: organisation, parent: project) }

      context "gcrf_challenge_area step" do
        subject { get_step :gcrf_challenge_area }

        it { is_expected.to skip_to_next_step }

        context "when activity is associated with the GCRF fund" do
          let(:activity) { create(:project_activity, organisation: organisation, parent: programme, source_fund_code: Fund::MAPPINGS["GCRF"]) }

          it { is_expected.to render_current_step }
        end
      end
    end
  end

  private

  def get_step(step)
    get :show, params: {activity_id: activity.id, id: step}
  end

  RSpec::Matchers.define :skip_to_next_step do
    match do |actual|
      expect(actual).to redirect_to(controller.next_wizard_path)
    end

    description do
      "skip to the next step (#{controller.next_step})"
    end

    failure_message do |actual|
      "expected to skip the next step (#{controller.step}), but didn't"
    end
  end

  RSpec::Matchers.define :render_current_step do
    match do |actual|
      expect(actual).to render_template(controller.step)
    end

    description do
      "render the current step"
    end

    failure_message do |actual|
      "expected to render the current form step (#{controller.step}), but didn't"
    end
  end
end
