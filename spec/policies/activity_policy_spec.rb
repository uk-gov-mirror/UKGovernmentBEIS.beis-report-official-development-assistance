require "rails_helper"

RSpec.describe ActivityPolicy do
  let(:user) { build_stubbed(:beis_user) }
  subject { described_class.new(user, activity) }

  describe "#show?" do
    context "when the activity doesn't have a level yet" do
      context "and the user belongs to the authoring organisation" do
        let(:activity) { create(:activity, :blank_form_state, level: nil, organisation: user.organisation) }
        it { is_expected.to permit_action(:show) }
      end

      context "and the user DOES NOT belong to the authoring organisation" do
        let(:another_organisation) { create(:organisation) }
        let(:activity) { create(:activity, :blank_form_state, level: nil, organisation: another_organisation) }
        it { is_expected.to forbid_action(:show) }
      end
    end

    context "when the user is a BEIS user" do
      let(:user) { build_stubbed(:beis_user) }
      context "when the activity is a fund" do
        let(:activity) { create(:fund_activity, organisation: user.organisation) }
        it { is_expected.to permit_action(:show) }
      end

      context "when the activity is a programme" do
        let(:activity) { create(:programme_activity, organisation: user.organisation) }
        it { is_expected.to permit_action(:show) }
      end

      context "when the activity is a project" do
        let(:activity) { create(:project_activity, organisation: user.organisation) }
        it { is_expected.to permit_action(:show) }
      end

      context "when the activity is a third_party_project" do
        let(:activity) { create(:third_party_project_activity, organisation: user.organisation) }
        it { is_expected.to permit_action(:show) }
      end
    end

    context "when the user is not a BEIS user" do
      let(:user) { build_stubbed(:delivery_partner_user) }
      context "when the activity is a fund" do
        let(:activity) { create(:fund_activity, organisation: user.organisation) }
        it { is_expected.to forbid_action(:show) }
      end

      context "when the activity is a programme" do
        let(:activity) { create(:programme_activity, organisation: user.organisation) }
        it { is_expected.to permit_action(:show) }
      end

      context "when the activity is a project" do
        let(:activity) { create(:project_activity, organisation: user.organisation) }
        it { is_expected.to permit_action(:show) }
      end

      context "when the activity is a third_party_project" do
        let(:activity) { create(:third_party_project_activity, organisation: user.organisation) }
        it { is_expected.to permit_action(:show) }
      end
    end
  end

  describe "#add_transaction?" do
    context "when the user belongs to the authoring organisation" do
      context "and the activity status is 'Spend in progress'" do
        let(:activity) { create(:activity, organisation: user.organisation, programme_status: "02") }
        it { is_expected.to permit_action(:add_transaction) }
      end

      context "and the activity status is not 'Spend in progress'" do
        let(:activity) { create(:activity, organisation: user.organisation, programme_status: "01") }
        it { is_expected.to forbid_action(:add_transaction) }
      end
    end

    context "when the user does NOT belong to the authoring organisation" do
      let(:another_organisation) { create(:organisation) }
      let(:activity) { create(:activity, organisation: another_organisation) }
      it { is_expected.to forbid_action(:add_transaction) }
    end
  end

  describe "#add_planned_disbursement?" do
    context "when the user belongs to the authoring organisation" do
      context "and the activity status is not 'Completed'" do
        let(:activity) { create(:activity, organisation: user.organisation, programme_status: "02") }
        it { is_expected.to permit_action(:add_planned_disbursement) }
      end

      context "and the activity status is 'Completed'" do
        let(:activity) { create(:activity, organisation: user.organisation, programme_status: "01") }
        it { is_expected.to forbid_action(:add_planned_disbursement) }
      end
    end

    context "when the user does NOT belong to the authoring organisation" do
      let(:another_organisation) { create(:organisation) }
      let(:activity) { create(:activity, organisation: another_organisation) }
      it { is_expected.to forbid_action(:add_planned_disbursement) }
    end
  end

  describe "#add_budget?" do
    context "when the user belongs to the authoring organisation" do
      context "and the activity status is not 'Completed'" do
        let(:activity) { create(:activity, organisation: user.organisation, programme_status: "02") }
        it { is_expected.to permit_action(:add_budget) }
      end

      context "and the activity status is 'Completed'" do
        let(:activity) { create(:activity, organisation: user.organisation, programme_status: "01") }
        it { is_expected.to forbid_action(:add_budget) }
      end
    end

    context "when the user does NOT belong to the authoring organisation" do
      let(:another_organisation) { create(:organisation) }
      let(:activity) { create(:activity, organisation: another_organisation) }
      it { is_expected.to forbid_action(:add_budget) }
    end
  end

  describe "#create?" do
    context "when the user belongs to the authoring organisation" do
      let(:activity) { create(:activity, organisation: user.organisation) }
      it { is_expected.to permit_action(:create) }
    end

    context "when the user does NOT belong to the authoring organisation" do
      let(:another_organisation) { create(:organisation) }
      let(:activity) { create(:activity, organisation: another_organisation) }
      it { is_expected.to forbid_action(:create) }
    end
  end

  describe "#update?" do
    context "when the user belongs to the authoring organisation" do
      let(:activity) { create(:activity, organisation: user.organisation) }
      it { is_expected.to permit_action(:update) }
    end

    context "when the user does NOT belong to the authoring organisation" do
      let(:another_organisation) { create(:organisation) }
      let(:activity) { create(:activity, organisation: another_organisation) }
      it { is_expected.to forbid_action(:update) }
    end
  end

  describe "#destroy?" do
    let(:activity) { create(:activity, organisation: user.organisation) }
    it { is_expected.to forbid_action(:destroy) }
  end
end
