require "rails_helper"

RSpec.describe PlannedDisbursement, type: :model do
  let(:activity) { build(:activity) }

  describe "validations" do
    it { should validate_presence_of(:planned_disbursement_type) }
    it { should validate_presence_of(:period_start_date) }
    it { should validate_presence_of(:currency) }
    it { should validate_presence_of(:value) }

    context "when the activity belongs to a delivery partner organisation" do
      before { activity.update(organisation: build_stubbed(:delivery_partner_organisation)) }

      it "should validate the prescence of report" do
        transaction = build_stubbed(:transaction, parent_activity: activity, report: nil)
        expect(transaction.valid?).to be false
      end
    end

    context "when the activity belongs to BEIS" do
      before { activity.update(organisation: build_stubbed(:beis_organisation)) }

      it "should not validate the prescence of report" do
        transaction = build_stubbed(:transaction, parent_activity: activity, report: nil)
        expect(transaction.valid?).to be true
      end
    end

    context "when adding a revision" do
      it "validates that the revised value is not the same as the prior version" do
        _original_planned_disbursement = create(
          :planned_disbursement,
          value: 10000,
          financial_quarter: 1,
          financial_year: 2020,
          planned_disbursement_type: "1"
        )
        revised_planned_disbursement = build(
          :planned_disbursement,
          value: 10000,
          financial_quarter: 1,
          financial_year: 2020,
          planned_disbursement_type: "2"
        )
        expect(revised_planned_disbursement.valid?).to be false
        expect(revised_planned_disbursement.errors.messages[:value]).to include(
          t("activerecord.errors.models.planned_disbursement.attributes.value.revised_value_not_the_same_as_original")
        )
      end

      it "does not check the prior version of a ingested planned disbursement" do
        activity = create(:activity, ingested: true)
        _original_planned_disbursement = create(
          :planned_disbursement,
          value: 10000,
          financial_quarter: 1,
          financial_year: 2020,
          planned_disbursement_type: "1",
          parent_activity: activity
        )
        revised_planned_disbursement = build(
          :planned_disbursement,
          value: 10000,
          financial_quarter: 1,
          financial_year: 2020,
          planned_disbursement_type: "2",
          parent_activity: activity
        )
        expect(revised_planned_disbursement.valid?).to be true
      end
    end
  end

  describe "#unknown_receiving_organisation_type?" do
    it "returns true when receiving organisation type is 0" do
      planned_disbursement = create(:planned_disbursement, receiving_organisation_type: "0")
      expect(planned_disbursement.unknown_receiving_organisation_type?).to be true

      planned_disbursement.update(receiving_organisation_type: "10")
      expect(planned_disbursement.unknown_receiving_organisation_type?).to be false
    end
  end
end
