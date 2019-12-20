require "rails_helper"

RSpec.describe Activity, type: :model do
  describe "relations" do
    it { should belong_to(:hierarchy) }
  end

  describe "constraints" do
    it { should validate_uniqueness_of(:identifier) }
  end

  describe "validations" do
    context "when title is blank" do
      subject { build(:activity, title: nil, wizard_status: :purpose) }
      it { should validate_presence_of(:title) }
    end

    context "when description is blank" do
      subject { build(:activity, description: nil, wizard_status: :purpose) }
      it { should validate_presence_of(:description) }
    end

    context "when sector is blank" do
      subject { build(:activity, sector: nil, wizard_status: :sector) }
      it { should validate_presence_of(:sector) }
    end

    context "when status is blank" do
      subject { build(:activity, status: nil, wizard_status: :status) }
      it { should validate_presence_of(:status) }
    end

    context "when planned_start_date is blank" do
      subject { build(:activity, planned_start_date: nil, wizard_status: :dates) }
      it { should_not validate_presence_of(:planned_start_date) }
    end

    context "when planned_end_date is blank" do
      subject { build(:activity, planned_end_date: nil, wizard_status: :dates) }
      it { should_not validate_presence_of(:planned_end_date) }
    end

    context "when actual_start_date is blank" do
      subject { build(:activity, actual_start_date: nil, wizard_status: :dates) }
      it { should_not validate_presence_of(:actual_start_date) }
    end

    context "when actual_end_date is blank" do
      subject { build(:activity, actual_end_date: nil, wizard_status: :dates) }
      it { should_not validate_presence_of(:actual_end_date) }
    end

    context "when recipient_region is blank" do
      subject { build(:activity, recipient_region: nil, wizard_status: :country) }
      it { should validate_presence_of(:recipient_region) }
    end

    context "when flow is blank" do
      subject { build(:activity, flow: nil, wizard_status: :flow) }
      it { should validate_presence_of(:flow) }
    end

    context "when finance is blank" do
      subject { build(:activity, finance: nil, wizard_status: :finance) }
      it { should validate_presence_of(:finance) }
    end

    context "when tied_status is blank" do
      subject { build(:activity, tied_status: nil, wizard_status: :tied_status) }
      it { should validate_presence_of(:tied_status) }
    end

    context "when the wizard_status is complete" do
      subject { build(:activity, wizard_status: "complete") }
      it { should validate_presence_of(:title) }
      it { should validate_presence_of(:description) }
      it { should validate_presence_of(:sector) }
      it { should validate_presence_of(:status) }
      it { should_not validate_presence_of(:planned_start_date) }
      it { should_not validate_presence_of(:planned_end_date) }
      it { should_not validate_presence_of(:actual_start_date) }
      it { should_not validate_presence_of(:actual_end_date) }
      it { should validate_presence_of(:recipient_region) }
      it { should validate_presence_of(:flow) }
      it { should validate_presence_of(:finance) }
      it { should validate_presence_of(:tied_status) }
    end
  end
end
