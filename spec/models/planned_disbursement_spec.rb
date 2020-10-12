require "rails_helper"

RSpec.describe PlannedDisbursement, type: :model do
  let(:activity) { build(:activity) }

  describe "validations" do
    it { should validate_presence_of(:planned_disbursement_type) }
    it { should validate_presence_of(:period_start_date) }
    it { should validate_presence_of(:currency) }
    it { should validate_presence_of(:value) }

    it "does not allow two original planned disbursements for the same activity, financial quarter and year" do
      beis = create(:beis_organisation)
      report = create(:report)
      first_planned_disbursement = create(:planned_disbursement, parent_activity: activity, financial_quarter: 1, financial_year: 2020)
      second_planned_disbursement = PlannedDisbursement.new(
        value: 1000,
        planned_disbursement_type: :original,
        financial_quarter: 1,
        financial_year: 2020,
        period_start_date: Date.parse("2020-04-01"),
        providing_organisation_name: beis.name,
        providing_organisation_type: beis.organisation_type,
        providing_organisation_reference: beis.iati_reference,
        currency: "GBP",
        parent_activity: activity,
        report: report
      )

      error_message = t("activerecord.errors.models.planned_disbursement.attributes.planned_disbursement_type.only_one_original",
        financial_quarter: first_planned_disbursement.financial_quarter,
        financial_year_start: first_planned_disbursement.financial_year,
        financial_year_end: first_planned_disbursement.financial_year + 1)

      expect(second_planned_disbursement).to be_invalid
      expect(second_planned_disbursement.errors[:base]).to eq [error_message]
    end

    it "does allow the same original planned disbursement when editing" do
      planned_disbursement = create(:planned_disbursement, parent_activity: activity, financial_quarter: 1, financial_year: 2020)
      planned_disbursement.value = "200000.00"

      expect(planned_disbursement).to be_valid
    end

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
          value: 11000,
          financial_quarter: 1,
          financial_year: 2020,
          planned_disbursement_type: :original
        )
        _fist_revised_planned_disbursement = create(
          :planned_disbursement,
          value: 10000,
          financial_quarter: 1,
          financial_year: 2020,
          planned_disbursement_type: :revised
        )
        revised_planned_disbursement = build(
          :planned_disbursement,
          value: 10000,
          financial_quarter: 1,
          financial_year: 2020,
          planned_disbursement_type: :revised
        )
        expect(revised_planned_disbursement).to be_invalid
        expect(revised_planned_disbursement.errors.messages[:value]).to eq [t("activerecord.errors.models.planned_disbursement.attributes.value.revised_value_not_the_same_as_original")]
      end

      it "does not check the prior version of a ingested planned disbursement" do
        activity = create(:activity, ingested: true)
        _original_planned_disbursement = create(
          :planned_disbursement,
          value: 10000,
          financial_quarter: 1,
          financial_year: 2020,
          planned_disbursement_type: :original,
          parent_activity: activity
        )
        revised_planned_disbursement = build(
          :planned_disbursement,
          value: 10000,
          financial_quarter: 1,
          financial_year: 2020,
          planned_disbursement_type: :revised,
          parent_activity: activity
        )
        expect(revised_planned_disbursement).to be_valid
      end
    end
  end
end
