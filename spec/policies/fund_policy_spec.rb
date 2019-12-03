require "rails_helper"

RSpec.describe FundPolicy do
  subject { described_class.new(user, fund) }

  let(:organisation) { create(:organisation) }
  let(:fund) { create(:fund, organisation: organisation) }

  context "as an administrator" do
    let(:user) { build_stubbed(:administrator) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }
  end

  context "as a delivery partner" do
    let(:user) { build_stubbed(:user) }
    let(:resolved_scope) do
      described_class::Scope.new(user, Fund.all).resolve
    end

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }

    context "with funds from my own organisation" do
      let(:user) { create(:user, organisations: [organisation]) }

      it "includes fund in resolved scope" do
        expect(resolved_scope).to include(fund)
      end
    end

    context "with funds from another organisation" do
      let(:other_organisation) { create(:organisation) }
      let(:forbidden_fund) { create(:fund, organisation: other_organisation) }

      it "does not include fund in resolved scope" do
        expect(resolved_scope).to_not include(forbidden_fund)
      end
    end
  end
end