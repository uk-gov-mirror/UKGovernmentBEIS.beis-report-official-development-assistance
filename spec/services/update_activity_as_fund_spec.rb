require "rails_helper"

RSpec.describe UpdateActivityAsFund do
  let(:beis) { create(:beis_organisation) }
  let(:activity) { create(:fund_activity, :blank_form_state) }

  describe "#call" do
    let(:result) { described_class.new(activity: activity).call }

    it "sets the parent form_state" do
      expect(result.form_state).to eq("parent")
    end

    it "sets the activity level to 'fund'" do
      expect(result.level).to eq("fund")
    end

    it "sets the funding organisation details to HMT" do
      expect(result.funding_organisation_name).to eq("HM Treasury")
      expect(result.funding_organisation_reference).to eq("GB-GOV-2")
      expect(result.funding_organisation_type).to eq("10")
    end

    it "sets the accountable organisation details to the service owner" do
      expect(result.accountable_organisation_name).to eq beis.name
      expect(result.accountable_organisation_reference).to eq beis.iati_reference
      expect(result.accountable_organisation_type).to eq beis.organisation_type
    end

    it "sets the extending organisation to BEIS" do
      expect(result.extending_organisation).to eq(beis)
    end
  end
end